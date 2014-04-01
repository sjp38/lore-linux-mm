From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Recent 3.x kernels: Memory leak causing OOMs
Date: Tue, 1 Apr 2014 15:04:01 +0100
Message-ID: <20140401140401.GZ7528@n2100.arm.linux.org.uk>
References: <alpine.DEB.2.02.1402161406120.26926@chino.kir.corp.google.com> <20140216225000.GO30257@n2100.arm.linux.org.uk> <1392670951.24429.10.camel@sakura.staff.proxad.net> <20140217210954.GA21483@n2100.arm.linux.org.uk> <20140315101952.GT21483@n2100.arm.linux.org.uk> <20140317180748.644d30e2@notabene.brown> <20140317181813.GA24144@arm.com> <20140317193316.GF21483@n2100.arm.linux.org.uk> <20140401091959.GA10912@n2100.arm.linux.org.uk> <20140401113851.GA15317@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-raid-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140401113851.GA15317@n2100.arm.linux.org.uk>
Sender: linux-raid-owner@vger.kernel.org
To: NeilBrown <neilb@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Kent Overstreet <koverstreet@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-raid@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Maxime Bizon <mbizon@freebox.fr>, linux-arm-kernel@lists.infradead.org
List-Id: linux-mm.kvack.org

On Tue, Apr 01, 2014 at 12:38:51PM +0100, Russell King - ARM Linux wrote:
> Consider what happens when bio_alloc_pages() fails.  j starts off as one
> for non-recovery operations, and we enter the loop to allocate the pages.
> j is post-decremented to zero.  So, bio = r1_bio->bios[0].
> 
> bio_alloc_pages(bio) fails, we jump to out_free_bio.  The first thing
> that does is increment j, so we free from r1_bio->bios[1] up to the
> number of raid disks, leaving r1_bio->bios[0] leaked as the r1_bio is
> then freed.

Neil,

Can you please review commit a07876064a0b7 (block: Add bio_alloc_pages)
which seems to have introduced this bug - it seems to have gone in during
the v3.10 merge window, and looks like it was never reviewed from the
attributations on the commit.

The commit message is brief, and inadequately describes the functional
change that the patch has - we go from "get up to RESYNC_PAGES into the
bio's io_vec" to "get all RESYNC_PAGES or fail completely".

Not withstanding the breakage of the error cleanup paths, is this an
acceptable change of behaviour here?

Thanks.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
