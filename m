Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 01AA56B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 05:08:29 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id o69so1959154wmd.1
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 02:08:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y15si1035154wmh.164.2018.02.23.02.08.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Feb 2018 02:08:27 -0800 (PST)
Date: Fri, 23 Feb 2018 10:10:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm, compaction: correct the bounds of
 __fragmentation_index()
Message-ID: <20180223091020.GS30681@dhcp22.suse.cz>
References: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
 <1518972475-11340-2-git-send-email-robert.m.harris@oracle.com>
 <20180219082649.GD21134@dhcp22.suse.cz>
 <E718672A-91A0-4A5A-91B5-A6CF1E9BD544@oracle.com>
 <20180219123932.GF21134@dhcp22.suse.cz>
 <90E01411-7511-4E6C-BDDF-74E0334E24FC@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <90E01411-7511-4E6C-BDDF-74E0334E24FC@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Harris <robert.m.harris@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Mel Gorman <mgorman@suse.de>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>

On Mon 19-02-18 14:30:36, Robert Harris wrote:
> 
> 
> > On 19 Feb 2018, at 12:39, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > On Mon 19-02-18 12:14:26, Robert Harris wrote:
> >> 
> >> 
> >>> On 19 Feb 2018, at 08:26, Michal Hocko <mhocko@kernel.org> wrote:
> >>> 
> >>> On Sun 18-02-18 16:47:55, robert.m.harris@oracle.com wrote:
> >>>> From: "Robert M. Harris" <robert.m.harris@oracle.com>
> >>>> 
> >>>> __fragmentation_index() calculates a value used to determine whether
> >>>> compaction should be favoured over page reclaim in the event of allocation
> >>>> failure.  The calculation itself is opaque and, on inspection, does not
> >>>> match its existing description.  The function purports to return a value
> >>>> between 0 and 1000, representing units of 1/1000.  Barring the case of a
> >>>> pathological shortfall of memory, the lower bound is instead 500.  This is
> >>>> significant because it is the default value of sysctl_extfrag_threshold,
> >>>> i.e. the value below which compaction should be avoided in favour of page
> >>>> reclaim for costly pages.
> >>>> 
> >>>> This patch implements and documents a modified version of the original
> >>>> expression that returns a value in the range 0 <= index < 1000.  It amends
> >>>> the default value of sysctl_extfrag_threshold to preserve the existing
> >>>> behaviour.
> >>> 
> >>> It is not really clear to me what is the actual problem you are trying
> >>> to solve by this patch. Is there any bug or are you just trying to
> >>> improve the current implementation to be more effective?
> >> 
> >> There is not a significant bug.
> >> 
> >> The first problem is that the mathematical expression in
> >> __fragmentation_index() is opaque, particularly given the lack of
> >> description in the comments or the original commit message.  This patch
> >> provides such a description.
> >> 
> >> Simply annotating the expression did not make sense since the formula
> >> doesn't work as advertised.  The fragmentation index is described as
> >> being in the range 0 to 1000 but the bounds of the formula are instead
> >> 500 to 1000.  This patch changes the formula so that its lower bound is
> >> 0.
> > 
> > But why do we want to fix that in the first place? Why don't we simply
> > deprecate the tunable and remove it altogether? Who is relying on tuning
> > this option. Considering how it doesn't work as advertised and nobody
> > complaining I have that feeling that it is not really used in wilda?|
> 
> I think it's a useful feature.  Ignoring any contrived test case, there
> will always be a lower limit on the degree of fragmentation that can be
> achieved by compaction.  If someone takes the trouble to measure this
> then it is entirely reasonable that he or she should be able to inhibit
> compaction for cases when fragmentation falls below some correspondingly
> sized threshold.

Do you have any practical examples?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
