Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D19336B0038
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 17:44:52 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id r10so885253pdi.38
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 14:44:52 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id yq9si2048573pab.58.2014.10.01.14.44.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 14:44:51 -0700 (PDT)
Message-ID: <542C749B.1040103@oracle.com>
Date: Wed, 01 Oct 2014 17:39:39 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] mm: poison critical mm/ structs
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com> <20141001140725.fd7f1d0cf933fbc2aa9fc1b1@linux-foundation.org>
In-Reply-To: <20141001140725.fd7f1d0cf933fbc2aa9fc1b1@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de

On 10/01/2014 05:07 PM, Andrew Morton wrote:
> On Mon, 29 Sep 2014 21:47:14 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>> Currently we're seeing a few issues which are unexplainable by looking at the
>> data we see and are most likely caused by a memory corruption caused
>> elsewhere.
>>
>> This is wasting time for folks who are trying to figure out an issue provided
>> a stack trace that can't really point out the real issue.
>>
>> This patch introduces poisoning on struct page, vm_area_struct, and mm_struct,
>> and places checks in busy paths to catch corruption early.
>>
>> This series was tested, and it detects corruption in vm_area_struct. Right now
>> I'm working on figuring out the source of the corruption, (which is a long
>> standing bug) using KASan, but the current code is useful as it is.
> 
> Is this still useful if/when kasan is in place?

Yes, the corruption we're seeing happens inside the struct rather than around it.
kasan doesn't look there.

When kasan is merged, we could complement this patchset by making kasan trap on
when the poison is getting written, rather than triggering a BUG in some place
else after we saw the corruption.

> It looks fairly cheap - I wonder if it should simply fall under
> CONFIG_DEBUG_VM rather than the new CONFIG_DEBUG_VM_POISON.

Config options are cheap as well :)

I'd rather expand it further and add poison/kasan trapping into other places such
as the vma interval tree rather than having to keep it "cheap".


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
