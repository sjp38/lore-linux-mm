Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE5A96B02E0
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 13:21:39 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id f72so5971637ioj.7
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 10:21:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v13sor3258093ita.34.2017.09.11.10.21.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 10:21:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170911094714.GD8503@quack2.suse.cz>
References: <150489930202.29460.5141541423730649272.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150489931339.29460.8760855724603300792.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170911094714.GD8503@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Sep 2017 10:21:36 -0700
Message-ID: <CAA9_cmfeMSUSh1FkdC=RW9jo1-e5sj5V+n6g99NOirukkWw=MA@mail.gmail.com>
Subject: Re: [RFC PATCH v8 2/2] mm: introduce MAP_SHARED_VALIDATE, a mechanism
 to safely define new mmap flags
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Mon, Sep 11, 2017 at 2:47 AM, Jan Kara <jack@suse.cz> wrote:
> On Fri 08-09-17 12:35:13, Dan Williams wrote:
>> The mmap(2) syscall suffers from the ABI anti-pattern of not validating
>> unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
>> mechanism to define new behavior that is known to fail on older kernels
>> without the support. Define a new MAP_SHARED_VALIDATE flag pattern that
>> is guaranteed to fail on all legacy mmap implementations.
>>
>> With this in place new flags can be defined as:
>>
>>     #define MAP_new (MAP_SHARED_VALIDATE | val)
>
> Is this changelog stale? Given MAP_SHARED_VALIDATE will be new mapping
> type, I'd expect we define new flags just as any other mapping flags...
> I see no reason why MAP_SHARED_VALIDATE should be or'ed to that.

True, it will just by a new MAP_TYPE plus new flags. I will fix this up comment.

[..]
>> diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
>> index 3b26cc62dadb..c32276c4196a 100644
>> --- a/arch/alpha/include/uapi/asm/mman.h
>> +++ b/arch/alpha/include/uapi/asm/mman.h
>> @@ -14,6 +14,7 @@
>>  #define MAP_TYPE     0x0f            /* Mask for type of mapping (OSF/1 is _wrong_) */
>>  #define MAP_FIXED    0x100           /* Interpret addr exactly */
>>  #define MAP_ANONYMOUS        0x10            /* don't use a file */
>> +#define MAP_SHARED_VALIDATE (MAP_SHARED|MAP_PRIVATE) /* validate extension flags */
>
> And I'd explicitely define MAP_SHARED_VALIDATE as the first unused value
> among mapping types (which is in fact enum embedded inside mapping flags).
> I.e. 0x03 on alpha, x86, and probably all other archs - it has nothing to
> do with MAP_SHARED|MAP_PRIVATE - it is just another type of the mapping
> which happens to have most of the MAP_SHARED semantics...

Ok, I'll make it 0x3 everywhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
