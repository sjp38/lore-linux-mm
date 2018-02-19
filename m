Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 872BA6B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 04:47:41 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e143so3971097wma.2
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 01:47:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f2si13943999wmh.242.2018.02.19.01.47.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Feb 2018 01:47:39 -0800 (PST)
Date: Mon, 19 Feb 2018 09:47:35 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/1] mm, compaction: correct the bounds of
 __fragmentation_index()
Message-ID: <20180219094735.g4sm4kxawjnojgyd@suse.de>
References: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
 <1518972475-11340-2-git-send-email-robert.m.harris@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1518972475-11340-2-git-send-email-robert.m.harris@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.m.harris@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>

On Sun, Feb 18, 2018 at 04:47:55PM +0000, robert.m.harris@oracle.com wrote:
> From: "Robert M. Harris" <robert.m.harris@oracle.com>
> 
> __fragmentation_index() calculates a value used to determine whether
> compaction should be favoured over page reclaim in the event of allocation
> failure.  The calculation itself is opaque and, on inspection, does not
> match its existing description.  The function purports to return a value
> between 0 and 1000, representing units of 1/1000.  Barring the case of a
> pathological shortfall of memory, the lower bound is instead 500.  This is
> significant because it is the default value of sysctl_extfrag_threshold,
> i.e. the value below which compaction should be avoided in favour of page
> reclaim for costly pages.
> 
> This patch implements and documents a modified version of the original
> expression that returns a value in the range 0 <= index < 1000.  It amends
> the default value of sysctl_extfrag_threshold to preserve the existing
> behaviour.
> 
> Signed-off-by: Robert M. Harris <robert.m.harris@oracle.com>

You have to update sysctl_extfrag_threshold as well for the new bounds.
It effectively makes it a no-op but it was a no-op already and adjusting
that default should be supported by data indicating it's safe.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
