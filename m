Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E027E6B006C
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 11:40:57 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so45982647pac.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 08:40:57 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.226])
        by mx.google.com with ESMTP id sg6si36727853pac.164.2015.03.18.08.40.56
        for <linux-mm@kvack.org>;
        Wed, 18 Mar 2015 08:40:56 -0700 (PDT)
Date: Wed, 18 Mar 2015 11:40:54 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V5] Allow compaction of unevictable pages
Message-ID: <20150318154054.GH3042@home.goodmis.org>
References: <1426267597-25811-1-git-send-email-emunson@akamai.com>
 <550332CE.7040404@redhat.com>
 <20150313190915.GA12589@akamai.com>
 <20150313201954.GB28848@dhcp22.suse.cz>
 <5506ACEC.9010403@suse.cz>
 <20150316134956.GA15324@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150316134956.GA15324@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, linux-rt-users@vger.kernel.org

On Mon, Mar 16, 2015 at 09:49:56AM -0400, Eric B Munson wrote:
> On Mon, 16 Mar 2015, Vlastimil Babka wrote:
> 
> > [CC += linux-api@]
> > 
> > Since this is a kernel-user-space API change, please CC linux-api@.
> > The kernel source file Documentation/SubmitChecklist notes that all
> > Linux kernel patches that change userspace interfaces should be CCed
> > to linux-api@vger.kernel.org, so that the various parties who are
> > interested in API changes are informed. For further information, see
> > https://urldefense.proofpoint.com/v2/url?u=https-3A__www.kernel.org_doc_man-2Dpages_linux-2Dapi-2Dml.html&d=AwIC-g&c=96ZbZZcaMF4w0F4jpN6LZg&r=aUmMDRRT0nx4IfILbQLv8xzE0wB9sQxTHI3QrQ2lkBU&m=GUotTNnv26L0HxtXrBgiHqu6kwW3ufx2_TQpXIA216c&s=IFFYQ7Zr-4SIaF3slOZqiSP_noyva42kCwVRxxDm5wo&e=
> 
> Added to the Cc list, thanks.
> 
> > 
> > 
> > On 03/13/2015 09:19 PM, Michal Hocko wrote:
> > >On Fri 13-03-15 15:09:15, Eric B Munson wrote:
> > >>On Fri, 13 Mar 2015, Rik van Riel wrote:
> > >>
> > >>>On 03/13/2015 01:26 PM, Eric B Munson wrote:
> > >>>
> > >>>>--- a/mm/compaction.c
> > >>>>+++ b/mm/compaction.c
> > >>>>@@ -1046,6 +1046,8 @@ typedef enum {
> > >>>>  	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
> > >>>>  } isolate_migrate_t;
> > >>>>
> > >>>>+int sysctl_compact_unevictable;
> > 
> > A comment here would be useful I think, as well as explicit default
> > value. Maybe also __read_mostly although I don't know how much that
> > matters.
> 
> I am going to sit on V6 for a couple of days incase anyone from rt wants
> to chime in.  But these will be in V6.
> 
> > 
> > I also wonder if it might be confusing that "compact_memory" is a
> > write-only trigger that doesn't even show under "sysctl -a", while
> > "compact_unevictable" is a read/write setting. But I don't have a
> > better suggestion right now.
> 
> Does allow_unevictable_compaction sound better?  It feels too much like
> variable naming conventions from other languages which seems to
> encourage verbosity to me, but does indicate a difference from
> compact_memory.
> 
> > 
> > >>>>+
> > >>>>  /*
> > >>>>   * Isolate all pages that can be migrated from the first suitable block,
> > >>>>   * starting at the block pointed to by the migrate scanner pfn within
> > >>>
> > >>>I suspect that the use cases where users absolutely do not want
> > >>>unevictable pages migrated are special cases, and it may make
> > >>>sense to enable sysctl_compact_unevictable by default.
> > >>
> > >>Given that sysctl_compact_unevictable=0 is the way the kernel behaves
> > >>now and the push back against always enabling compaction on unevictable
> > >>pages, I left the default to be the behavior as it is today.
> > >
> > >The question is _why_ we have this behavior now. Is it intentional?
> > 
> > It's there since 748446bb6 ("mm: compaction: memory compaction
> > core"). Commit c53919adc0 ("mm: vmscan: remove lumpy reclaim")
> > changes the comment in __isolate_lru_page() handling of unevictable
> > pages to mention compaction explicitly. It could have been
> > accidental in 748446bb6 though, maybe it just reused
> > __isolate_lru_page() for compaction - it seems that the skipping of
> > unevictable was initially meant to optimize lumpy reclaim.
> > 
> > >e46a28790e59 (CMA: migrate mlocked pages) is a precedence in that
> > 
> > Well, CMA and realtime kernels are probably mutually exclusive enough.
> > 
> > >direction. Vlastimil has then changed that by edc2ca612496 (mm,
> > >compaction: move pageblock checks up from isolate_migratepages_range()).
> > >There is no mention about mlock pages so I guess it was more an
> > >unintentional side effect of the patch. At least that is my current
> > >understanding. I might be wrong here.
> > 
> > Although that commit did change unintentionally more details that I
> > would have liked (unfortunately), I think you are wrong on this one.
> > ISOLATE_UNEVICTABLE is still passed from
> > isolate_migratepages_range() which is used by CMA, while the
> > compaction variant isolate_migratepages() does not pass it. So it's
> > kept CMA-specific as before.
> > 
> > >The thing about RT is that it is not usable with the upstream kernel
> > >without the RT patchset AFAIU. So the default should be reflect what is
> > >better for the standard kernel. RT loads have to tune the system anyway
> > >so it is not so surprising they would disable this option as well. We
> > >should help those guys and do not require them to touch the code but the
> > >knob is reasonable IMHO.
> > >
> > >Especially when your changelog suggests that having this enabled by
> > >default is beneficial for the standard kernel.
> > 
> > I agree, but if there's a danger of becoming too of a bikeshed
> > topic, I'm fine with keeping the default same as current behavior
> > and changing it later. Or maybe we should ask some -rt mailing list
> > instead of just Peter and Thomas?
> 
> According to the rt wiki, there is no -rt development list so lkml is
> it.  I will change the default to 1 for V6 if I don't hear otherwise by
> the time I get back around to spinning V6.
> 

For kernel development, yes. But this change affects users. Cc'ing the
linux-rt-users mailing list (which I did) is appropriate in this case.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
