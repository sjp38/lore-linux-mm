Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA616B0069
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 12:44:10 -0400 (EDT)
Received: by mail-yh0-f46.google.com with SMTP id f73so4119370yha.19
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 09:44:09 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i47si772799yha.133.2014.10.08.09.44.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Oct 2014 09:44:08 -0700 (PDT)
Message-ID: <543569CD.4060309@oracle.com>
Date: Wed, 08 Oct 2014 12:43:57 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] mm: poison critical mm/ structs
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com> <20141001140725.fd7f1d0cf933fbc2aa9fc1b1@linux-foundation.org> <542C749B.1040103@oracle.com> <alpine.LSU.2.11.1410020154500.6444@eggly.anvils> <542D680E.8010909@oracle.com> <54346623.6000309@intel.com>
In-Reply-To: <54346623.6000309@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de

On 10/07/2014 06:16 PM, Dave Hansen wrote:
> On 10/02/2014 07:58 AM, Sasha Levin wrote:
>>>> What does this add on top of slab poisoning?  Some checks in some
>>>> mm places while the object is active, I guess: why not base those
>>>> on slab poisoning?  And add them in as appropriate to the problem
>>>> at hand, when a problem is seen.
>> The extra you're getting is detecting corruption that happened
>> inside the object rather than around it.
> 
> Isn't this more akin to redzoning that poisoning?
> 
> I'm not sure I follow the logic here.  The poison is inside the object,
> but it's now at the edges.  With slub at least, you get a redzone right
> after the object(s):
> 
> 	{ OBJ } | REDZONE | { OBJ } | REDZONE | ...
> 
> With this patch, you'd get something along these lines:
> 
> 	{ POISON | OBJ | POISON } { POISON | OBJ | POISON }  ...
> 
> So if somebody overflows OBJ, they'll hit the redzone/poison in either
> case.  If they're randomly scribbling on memory, their likelihood of
> hitting the redzone/poison is proportional to the size of the
> redzone/poison.
> 
> The only place this really helps is if someone overflows from a
> non-redzoned page or structure in to the beginning of a slub redzoned
> one.  The fact that the redzone is at the end means we'll miss it.
> 
> But, all that means is that we should probably add redzones to the
> beginning of slub objects, not just the end.  That doesn't help us with
> 'struct page' of course, but it does for the mm_struct and vma.

This patchset is based on an actual issue we're seeing where the vma
gets corrupted without triggering any of the slub redzones.

Testing this patchset locally confirmed that while slub redzones stay
intact, the poison fields get overwritten - so now we're able to catch
the corruption after it happened.

I'm not sure what's the scenario that causes that, but once we figure
that out I could have a better response to your question...


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
