Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF426B0038
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 04:24:16 -0500 (EST)
Received: by wikq8 with SMTP id q8so67380812wik.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 01:24:16 -0800 (PST)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id ci5si6075417wjc.170.2015.11.03.01.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 01:24:15 -0800 (PST)
Received: by wijp11 with SMTP id p11so67477436wij.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 01:24:15 -0800 (PST)
Message-ID: <56387D3C.5020003@plexistor.com>
Date: Tue, 03 Nov 2015 11:24:12 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] osd fs: __r4w_get_page rely on PageUptodate for uptodate
References: <alpine.LSU.2.11.1510291137430.3369@eggly.anvils> <5635E2B4.5070308@electrozaur.com> <alpine.LSU.2.11.1511011513240.11427@eggly.anvils> <5637437C.4070306@electrozaur.com> <alpine.LSU.2.11.1511021813010.1013@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1511021813010.1013@eggly.anvils>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Lameter <cl@linux.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, osd-dev@open-osd.org

On 11/03/2015 04:49 AM, Hugh Dickins wrote:
> On Mon, 2 Nov 2015, Boaz Harrosh wrote:
>> On 11/02/2015 01:39 AM, Hugh Dickins wrote:
>> <>
>>>> This patch is not correct!
>>>
>>> I think you have actually confirmed that the patch is correct:
>>> why bother to test PageDirty or PageWriteback when PageUptodate
>>> already tells you what you need?
>>>
>>> Or do these filesystems do something unusual with PageUptodate
>>> when PageDirty is set?  I didn't find it.
>>>
>>
>> This is kind of delicate stuff. It took me a while to get it right
>> when I did it. I don't remember all the details.
>>
>> But consider this option:
> 
> Thanks, yes, it helps to have a concrete example in front of us.
> 
>>
>> exofs_write_begin on a full PAGE_CACHE_SIZE, the page is instantiated
>> new in page-cache is that PageUptodate(page) then? I thought not.
> 
> Right, PageUptodate must not be set until the page has been filled with
> the correct data.  Nor is PageDirty or PageWriteback set at this point,
> actually.
> 
> Once page is filled with the correct data, either exofs_write_end()
> (which uses simple_write_end()) or (internally) exofs_commit_chunk()
> is called.
> 
>> (exofs does not set that)
> 
> It's simple_write_end() or exofs_commit_chunk() which SetPageUptodate
> in this case.  And after that each calls set_page_dirty(), which does
> the SetPageDirty, before unlocking the page which was supplied locked
> by exofs_write_begin().
> 
> So I don't see where the page is PageDirty without being PageUptodate.
> 
>>
>> Now that page I do not want to read in. The latest data is in memory.
>> (Same when this page is in writeback, dirty-bit is cleared)
> 
> Understood, but that's what PageUptodate is for.
> 
> (Quite what happens if there's a write error is not so clear: I think
> that typically PageError gets set and PageUptodate cleared, to read
> back in from disk what's actually there - but lose the data we wanted
> to write; but I can understand different filesystems making different
> choices there, and didn't study exofs's choice.)
> 
>>
>> So for sure if page is dirty or writeback then we surly do not need a read.
>> only if not then we need to consider the  PageUptodate(page) state.
> 
> PageUptodate is the proper flag to check, to ask if the page contains
> the correct data: there is no need to consider Dirty or Writeback.
> 
>>
>> Do you think the code is actually wrong as is?
> 
> Not that I know of: just a little too complicated and confusing.
> 
> But becomes slightly wrong if my simplification to page migration
> goes through, since that introduces an instant when PageDirty is set
> before the new page contains the correct data and is marked Uptodate.
> Hence my patch.
> 
>>
>> BTW: Very similar code is in fs/nfs/objlayout/objio_osd.c::__r4w_get_page
> 
> Indeed, the patch makes the same adjustment to that code too.
> 

OK thanks. Let me setup and test your patch. On top of 4.3 is good?
I'll send you a tested-by once I'm done.

Boaz

>>
>>> Thanks,
>>> Hugh
>>>
>> <>
>>
>> Thanks
>> Boaz
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
