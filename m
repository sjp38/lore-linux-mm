From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Recent 3.x kernels: Memory leak causing OOMs
Date: Tue, 1 Apr 2014 12:38:51 +0100
Message-ID: <20140401113851.GA15317@n2100.arm.linux.org.uk>
References: <20140216200503.GN30257@n2100.arm.linux.org.uk> <alpine.DEB.2.02.1402161406120.26926@chino.kir.corp.google.com> <20140216225000.GO30257@n2100.arm.linux.org.uk> <1392670951.24429.10.camel@sakura.staff.proxad.net> <20140217210954.GA21483@n2100.arm.linux.org.uk> <20140315101952.GT21483@n2100.arm.linux.org.uk> <20140317180748.644d30e2@notabene.brown> <20140317181813.GA24144@arm.com> <20140317193316.GF21483@n2100.arm.linux.org.uk> <20140401091959.GA10912@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-raid-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140401091959.GA10912@n2100.arm.linux.org.uk>
Sender: linux-raid-owner@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: NeilBrown <neilb@suse.de>, linux-raid@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Maxime Bizon <mbizon@freebox.fr>, linux-arm-kernel@lists.infradead.org
List-Id: linux-mm.kvack.org

On Tue, Apr 01, 2014 at 10:19:59AM +0100, Russell King - ARM Linux wrote:
> On Mon, Mar 17, 2014 at 07:33:16PM +0000, Russell King - ARM Linux wrote:
> > On Mon, Mar 17, 2014 at 06:18:13PM +0000, Catalin Marinas wrote:
> > > On Mon, Mar 17, 2014 at 06:07:48PM +1100, NeilBrown wrote:
> > > > On Sat, 15 Mar 2014 10:19:52 +0000 Russell King - ARM Linux
> > > > <linux@arm.linux.org.uk> wrote:
> > > > > unreferenced object 0xc3c3f880 (size 256):
> > > > >   comm "md2_resync", pid 4680, jiffies 638245 (age 8615.570s)
> > > > >   hex dump (first 32 bytes):
> > > > >     00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 f0  ................
> > > > >     00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00  ................
> > > > >   backtrace:
> > > > >     [<c008d4f0>] __save_stack_trace+0x34/0x40
> > > > >     [<c008d5f0>] create_object+0xf4/0x214
> > > > >     [<c02da114>] kmemleak_alloc+0x3c/0x6c
> > > > >     [<c008c0d4>] __kmalloc+0xd0/0x124
> > > > >     [<c00bb124>] bio_alloc_bioset+0x4c/0x1a4
> > > > >     [<c021206c>] r1buf_pool_alloc+0x40/0x148
> > > > >     [<c0061160>] mempool_alloc+0x54/0xfc
> > > > >     [<c0211938>] sync_request+0x168/0x85c
> > > > >     [<c021addc>] md_do_sync+0x75c/0xbc0
> > > > >     [<c021b594>] md_thread+0x138/0x154
> > > > >     [<c0037b48>] kthread+0xb0/0xbc
> > > > >     [<c0013190>] ret_from_fork+0x14/0x24
> > > > >     [<ffffffff>] 0xffffffff
> > > > > 
> > > > > with 3077 of these in the debug file.  3075 are for "md2_resync" and
> > > > > two are for "md4_resync".
> > > > > 
> > > > > /proc/slabinfo shows for this bucket:
> > > > > kmalloc-256         3237   3450    256   15    1 : tunables  120   60    0 : slabdata    230    230      0
> > > > > 
> > > > > but this would only account for about 800kB of memory usage, which itself
> > > > > is insignificant - so this is not the whole story.
> > > > > 
> > > > > It seems that this is the culpret for the allocations:
> > > > >         for (j = pi->raid_disks ; j-- ; ) {
> > > > >                 bio = bio_kmalloc(gfp_flags, RESYNC_PAGES);
> > > > > 
> > > > > Since RESYNC_PAGES will be 64K/4K=16, each struct bio_vec is 12 bytes
> > > > > (12 * 16 = 192) plus the size of struct bio, which would fall into this
> > > > > bucket.
> > > > > 
> > > > > I don't see anything obvious - it looks like it isn't every raid check
> > > > > which loses bios.  Not quite sure what to make of this right now.

I now see something very obvious, having had the problem again, dumped
the physical memory to file, and inspected the full leaked struct bio.
What I find is that the leaked struct bio's have a bi_cnt of one, which
confirms that they were never freed - free'd struct bio's would have a
bi_cnt of zero due to the atomic_dec_and_test() before bio_free() inside
bio_put().

When looking at the bi_inline_vecs, I see that there was a failure to
allocate a page.  Now, let's look at what r1buf_pool_alloc() does:

        for (j = pi->raid_disks ; j-- ; ) {
                bio = bio_kmalloc(gfp_flags, RESYNC_PAGES);
                if (!bio)
                        goto out_free_bio;
                r1_bio->bios[j] = bio;
        }

        if (test_bit(MD_RECOVERY_REQUESTED, &pi->mddev->recovery))
                j = pi->raid_disks;
        else
                j = 1;
        while(j--) {
                bio = r1_bio->bios[j];
                bio->bi_vcnt = RESYNC_PAGES;

                if (bio_alloc_pages(bio, gfp_flags))
                        goto out_free_bio;
        }

out_free_bio:
        while (++j < pi->raid_disks)
                bio_put(r1_bio->bios[j]);
        r1bio_pool_free(r1_bio, data);

Consider what happens when bio_alloc_pages() fails.  j starts off as one
for non-recovery operations, and we enter the loop to allocate the pages.
j is post-decremented to zero.  So, bio = r1_bio->bios[0].

bio_alloc_pages(bio) fails, we jump to out_free_bio.  The first thing
that does is increment j, so we free from r1_bio->bios[1] up to the
number of raid disks, leaving r1_bio->bios[0] leaked as the r1_bio is
then freed.

The obvious fix is to set j to -1 before jumping to out_free_bio on
bio_alloc_pages() failure.  However, that's not the end of the story -
there's more leaks here.

bio_put() will not free the pages allocated by the previously successful
bio_alloc_pages().  What's more is that I don't see any function in BIO
which performs that function, which makes me wonder how many other places
in the kernel dealing with BIOs end up leaking like this.

Anyway, this is what I've come up with - it's not particularly nice,
but hopefully it will plug this leak.  I'm now running with this patch
in place, and time will tell.

 drivers/md/raid1.c | 30 ++++++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
index aacf6bf352d8..604bad2fa442 100644
--- a/drivers/md/raid1.c
+++ b/drivers/md/raid1.c
@@ -123,8 +123,14 @@ static void * r1buf_pool_alloc(gfp_t gfp_flags, void *data)
 		bio = r1_bio->bios[j];
 		bio->bi_vcnt = RESYNC_PAGES;
 
-		if (bio_alloc_pages(bio, gfp_flags))
-			goto out_free_bio;
+		if (bio_alloc_pages(bio, gfp_flags)) {
+			/*
+			 * Mark this as having no pages - bio_alloc_pages
+			 * removes any it allocated.
+			 */
+			bio->bi_vcnt = 0;
+			goto out_free_all_bios;
+		}
 	}
 	/* If not user-requests, copy the page pointers to all bios */
 	if (!test_bit(MD_RECOVERY_REQUESTED, &pi->mddev->recovery)) {
@@ -138,9 +144,25 @@ static void * r1buf_pool_alloc(gfp_t gfp_flags, void *data)
 
 	return r1_bio;
 
+out_free_all_bios:
+	j = -1;
 out_free_bio:
-	while (++j < pi->raid_disks)
-		bio_put(r1_bio->bios[j]);
+	while (++j < pi->raid_disks) {
+		bio = r1_bio->bios[j];
+		if (bio->bi_vcnt) {
+			struct bio_vec *bv;
+			int i;
+			/*
+			 * Annoyingly, BIO has no way to do this, so we have
+			 * to do it manually.  Given the trouble here, and
+			 * the lack of BIO support for cleaning up, I don't
+			 * care about linux/bio.h's comment about this helper.
+			 */
+			bio_for_each_segment_all(bv, bio, i)
+				__free_page(bv->bv_page);
+		}
+		bio_put(bio);
+	}
 	r1bio_pool_free(r1_bio, data);
 	return NULL;
 }


-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
