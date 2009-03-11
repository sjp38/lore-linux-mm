Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 83C886B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 09:01:46 -0400 (EDT)
Date: Wed, 11 Mar 2009 21:00:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090311130022.GA22453@localhost>
References: <20090310105523.3dfd4873@mjolnir.ossman.eu> <20090310122210.GA8415@localhost> <20090310131155.GA9654@localhost> <20090310212118.7bf17af6@mjolnir.ossman.eu> <20090311013739.GA7078@localhost> <20090311075703.35de2488@mjolnir.ossman.eu> <20090311071445.GA13584@localhost> <20090311082658.06ff605a@mjolnir.ossman.eu> <20090311073619.GA26691@localhost> <20090311085738.4233df4e@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090311085738.4233df4e@mjolnir.ossman.eu>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

Hi Pierre,

On Wed, Mar 11, 2009 at 09:57:38AM +0200, Pierre Ossman wrote:
> On Wed, 11 Mar 2009 15:36:19 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > 
> > A quick question: are there any possibility of ftrace memory reservation?
> > 
> 
> You tell me. CONFIG_FTRACE was always disabled, but CONFIG_HAVE_*FTRACE
> is always on. FTRACE wasn't included in 2.6.26 though, and the bisect
> showed only ftrace commits. So it would explain things.

I worked up a simple debugging patch. Since the missing pages are
continuously spanned, several stack dumping shall be enough to catch
the page consumer.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 27b8681..c0df7fd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1087,6 +1087,13 @@ again:
 			goto failed;
 	}
 
+	/* wfg - hunting the 40000 missing pages */
+	{
+		unsigned long pfn = page_to_pfn(page);
+		if (pfn > 0x1000 && (pfn & 0xfff) <= 1)
+			dump_stack();
+	}
+
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone);
 	local_irq_restore(flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
