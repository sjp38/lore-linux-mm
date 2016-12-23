Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4D76B039F
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 05:01:36 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 17so390534674pfy.2
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 02:01:36 -0800 (PST)
Received: from mail-pg0-x229.google.com (mail-pg0-x229.google.com. [2607:f8b0:400e:c05::229])
        by mx.google.com with ESMTPS id z43si7890342plh.111.2016.12.23.02.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Dec 2016 02:01:35 -0800 (PST)
Received: by mail-pg0-x229.google.com with SMTP id i5so43052218pgh.2
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 02:01:35 -0800 (PST)
Date: Fri, 23 Dec 2016 02:01:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
In-Reply-To: <20161223085150.GA23109@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1612230154450.88514@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com> <20161222100009.GA6055@dhcp22.suse.cz> <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com> <20161223085150.GA23109@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 23 Dec 2016, Michal Hocko wrote:

> > The offering of defer breaks backwards compatibility with previous 
> > settings of defrag=madvise, where we could set madvise(MADV_HUGEPAGE) on 
> > .text segment remap and try to force thp backing if available but not 
> > directly reclaim for non VM_HUGEPAGE vmas.
> 
> I do not understand the backwards compatibility issue part here. Maybe I
> am missing something but the semantic of defrag=madvise hasn't changed
> and a new flag can hardly break backward compatibility.
> 

We have no way to compact memory for users who are not using 
MADV_HUGEPAGE, which is some customers, others require MADV_HUGEPAGE for 
.text segment remap while loading their binary, without defrag=always or 
defrag=defer.  The problem is that we want to demand direct compact for 
MADV_HUGEPAGE: they _really_ want hugepages, it's the point of the 
madvise.  We have no setting, without this patch, to ask for background 
compaction for everybody so that their fault does not have long latency 
and for some customers to demand compaction.  It's a userspace decision, 
not a kernel decision, and we have lost that ability.

> > This was very advantageous.  
> > We prefer that to stay unchanged and allow kcompactd compaction to be 
> > triggered in background by everybody else as opposed to direct reclaim.  
> > We do not have that ability without this patch.
> 
> So why don't you use defrag=madvise?
> 

Um, wtf?  Prior to the patch, we used defrag=always because we do not have 
low latency option; everybody was forced into it.  Now that we do have 
the option, we wish to use deferred compaction so that we have opportunity 
to fault hugepages in near future.  We also have userspace apps, and 
others have database apps, which want hugepages and are ok with any 
latency.  This should not be a difficult point to understand.  Allow the 
user to define if they are willing to accept latency with MADV_HUGEPAGE.

> I disagree. I think the current set of defrag values should be
> sufficient. We can completely disable direct reclaim, enable it only for
> opt-in, enable for all and never allow to stall. The advantage of this
> set of values is that they have _clear_ semantic and behave
> consistently. If you change defer to "almost never stall except when
> MADV_HUGEPAGE" then the semantic is less clear. Admin might have a good
> reason to never allow stalls - especially when he doesn't have a control
> over the code he is running. Your patch would break this usecase.
> 

?????? Why does the admin care if a user's page fault wants to reclaim to 
get high order memory?  The user incurs the penalty for MADV_HUGEPAGE, it 
always has.  Lol.

This objection is nonsensical.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
