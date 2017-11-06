Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 090486B0260
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 12:57:55 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id m81so20050466ioi.15
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 09:57:55 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0081.hostedemail.com. [216.40.44.81])
        by mx.google.com with ESMTPS id 66si8599248itb.83.2017.11.06.09.57.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 09:57:54 -0800 (PST)
Message-ID: <1509991069.2431.45.camel@perches.com>
Subject: Re: [PATCH] mm, sparse: do not swamp log with huge vmemmap
 allocation failures
From: Joe Perches <joe@perches.com>
Date: Mon, 06 Nov 2017 09:57:49 -0800
In-Reply-To: <20171106173511.GA32336@cmpxchg.org>
References: <20171106092228.31098-1-mhocko@kernel.org>
	 <20171106173511.GA32336@cmpxchg.org>
Content-Type: multipart/mixed; boundary="=-idGoc9ZTC8IXc9QLTUfg"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


--=-idGoc9ZTC8IXc9QLTUfg
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On Mon, 2017-11-06 at 12:35 -0500, Johannes Weiner wrote:
> On Mon, Nov 06, 2017 at 10:22:28AM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > While doing a memory hotplug tests under a heavy memory pressure we have
> > noticed too many page allocation failures when allocating vmemmap memmap
> > backed by huge page
> > [146792.281354] kworker/u3072:1: page allocation failure: order:9, mode:0x24084c0(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO)
> > [...]
> > [146792.281394] Call Trace:
> > [146792.281430]  [<ffffffff81019a99>] dump_trace+0x59/0x310
> > [146792.281436]  [<ffffffff81019e3a>] show_stack_log_lvl+0xea/0x170
> > [146792.281440]  [<ffffffff8101abc1>] show_stack+0x21/0x40
> > [146792.281448]  [<ffffffff8130f040>] dump_stack+0x5c/0x7c
> > [146792.281464]  [<ffffffff8118c982>] warn_alloc_failed+0xe2/0x150
> > [146792.281471]  [<ffffffff8118cddd>] __alloc_pages_nodemask+0x3ed/0xb20
> > [146792.281489]  [<ffffffff811d3aaf>] alloc_pages_current+0x7f/0x100
> > [146792.281503]  [<ffffffff815dfa2c>] vmemmap_alloc_block+0x79/0xb6
> > [146792.281510]  [<ffffffff815dfbd3>] __vmemmap_alloc_block_buf+0x136/0x145
> > [146792.281524]  [<ffffffff815dd0c5>] vmemmap_populate+0xd2/0x2b9
> > [146792.281529]  [<ffffffff815dffd9>] sparse_mem_map_populate+0x23/0x30
> > [146792.281532]  [<ffffffff815df88d>] sparse_add_one_section+0x68/0x18e
> > [146792.281537]  [<ffffffff815d9f5a>] __add_pages+0x10a/0x1d0
> > [146792.281553]  [<ffffffff8106249a>] arch_add_memory+0x4a/0xc0
> > [146792.281559]  [<ffffffff815da1f9>] add_memory_resource+0x89/0x160
> > [146792.281564]  [<ffffffff815da33d>] add_memory+0x6d/0xd0
> > [146792.281585]  [<ffffffff813d36c4>] acpi_memory_device_add+0x181/0x251
> > [146792.281597]  [<ffffffff813946e5>] acpi_bus_attach+0xfd/0x19b
> > [146792.281602]  [<ffffffff81394866>] acpi_bus_scan+0x59/0x69
> > [146792.281604]  [<ffffffff813949de>] acpi_device_hotplug+0xd2/0x41f
> > [146792.281608]  [<ffffffff8138db67>] acpi_hotplug_work_fn+0x1a/0x23
> > [146792.281623]  [<ffffffff81093cee>] process_one_work+0x14e/0x410
> > [146792.281630]  [<ffffffff81094546>] worker_thread+0x116/0x490
> > [146792.281637]  [<ffffffff810999ed>] kthread+0xbd/0xe0
> > [146792.281651]  [<ffffffff815e4e7f>] ret_from_fork+0x3f/0x70
> > 
> > and we do see many of those because essentially every the allocation
> > failes for each memory section. This is overly excessive way to tell
> > user that there is nothing to really worry about because we do have
> > a fallback mechanism to use base pages. The only downside might be a
> > performance degradation due to TLB pressure.
> > 
> > This patch changes vmemmap_alloc_block to use __GFP_NOWARN and warn
> > explicitly once on the first allocation failure. This will reduce the
> > noise in the kernel log considerably, while we still have an indication
> > that a performance might be impacted.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> > Hi,
> > this has somehow fell of my radar completely. The patch is essentially
> > what Johannes suggested [1] so I have added his s-o-b and added the
> > changelog into it.
> 
> Looks good to me.

I think it'd be better to change the ratelimit state
to something like once a minute
---
 mm/page_alloc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 82e6d2c914ab..af3f92beec04 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3269,8 +3269,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 {
 	struct va_format vaf;
 	va_list args;
-	static DEFINE_RATELIMIT_STATE(nopage_rs, DEFAULT_RATELIMIT_INTERVAL,
-				      DEFAULT_RATELIMIT_BURST);
+	static DEFINE_RATELIMIT_STATE(nopage_rs, HZ * 60, 1);
 
 	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
 		return;
--=-idGoc9ZTC8IXc9QLTUfg
Content-Disposition: attachment; filename="1.difd"
Content-Type: text/plain; name="1.difd"; charset="ISO-8859-1"
Content-Transfer-Encoding: base64

IG1tL3BhZ2VfYWxsb2MuYyB8IDMgKy0tCiAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyks
IDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbW0vcGFnZV9hbGxvYy5jIGIvbW0vcGFnZV9h
bGxvYy5jCmluZGV4IDgyZTZkMmM5MTRhYi4uYWYzZjkyYmVlYzA0IDEwMDY0NAotLS0gYS9tbS9w
YWdlX2FsbG9jLmMKKysrIGIvbW0vcGFnZV9hbGxvYy5jCkBAIC0zMjY5LDggKzMyNjksNyBAQCB2
b2lkIHdhcm5fYWxsb2MoZ2ZwX3QgZ2ZwX21hc2ssIG5vZGVtYXNrX3QgKm5vZGVtYXNrLCBjb25z
dCBjaGFyICpmbXQsIC4uLikKIHsKIAlzdHJ1Y3QgdmFfZm9ybWF0IHZhZjsKIAl2YV9saXN0IGFy
Z3M7Ci0Jc3RhdGljIERFRklORV9SQVRFTElNSVRfU1RBVEUobm9wYWdlX3JzLCBERUZBVUxUX1JB
VEVMSU1JVF9JTlRFUlZBTCwKLQkJCQkgICAgICBERUZBVUxUX1JBVEVMSU1JVF9CVVJTVCk7CisJ
c3RhdGljIERFRklORV9SQVRFTElNSVRfU1RBVEUobm9wYWdlX3JzLCBIWiAqIDYwLCAxKTsKIAog
CWlmICgoZ2ZwX21hc2sgJiBfX0dGUF9OT1dBUk4pIHx8ICFfX3JhdGVsaW1pdCgmbm9wYWdlX3Jz
KSkKIAkJcmV0dXJuOwo=


--=-idGoc9ZTC8IXc9QLTUfg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
