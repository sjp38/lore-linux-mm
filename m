Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C2E4E6B02CB
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 16:05:29 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id u5so49867224pgi.7
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 13:05:29 -0800 (PST)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id u28si4013993pfl.22.2016.12.22.13.05.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 13:05:28 -0800 (PST)
Received: by mail-pg0-x22f.google.com with SMTP id i5so36476510pgh.2
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 13:05:28 -0800 (PST)
Date: Thu, 22 Dec 2016 13:05:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
In-Reply-To: <20161222100009.GA6055@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com> <20161222100009.GA6055@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 22 Dec 2016, Michal Hocko wrote:

> > Currently, when defrag is set to "madvise", thp allocations will direct
> > reclaim.  However, when defrag is set to "defer", all thp allocations do
> > not attempt reclaim regardless of MADV_HUGEPAGE.
> > 
> > This patch always directly reclaims for MADV_HUGEPAGE regions when defrag
> > is not set to "never."  The idea is that MADV_HUGEPAGE regions really
> > want to be backed by hugepages and are willing to endure the latency at
> > fault as it was the default behavior prior to commit 444eb2a449ef ("mm:
> > thp: set THP defrag by default to madvise and add a stall-free defrag
> > option").
> 
> AFAIR "defer" is implemented exactly as intended. To offer a never-stall
> but allow to form THP in the background option. The patch description
> doesn't explain why this is not good anymore. Could you give us more
> details about the motivation and why "madvise" doesn't work for
> you? This is a user visible change so the reason should better be really
> documented and strong.
> 

The offering of defer breaks backwards compatibility with previous 
settings of defrag=madvise, where we could set madvise(MADV_HUGEPAGE) on 
.text segment remap and try to force thp backing if available but not 
directly reclaim for non VM_HUGEPAGE vmas.  This was very advantageous.  
We prefer that to stay unchanged and allow kcompactd compaction to be 
triggered in background by everybody else as opposed to direct reclaim.  
We do not have that ability without this patch.

Without this patch, we will be forced to offer multiple sysfs tunables to 
define (1) direct vs background compact, (2) madvise behavior, (3) always, 
(4) never and we cannot have 2^4 settings for "defrag" alone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
