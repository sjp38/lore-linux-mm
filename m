Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id EAEA96B0038
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 20:11:51 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id n184so638145803oig.1
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 17:11:51 -0800 (PST)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id h22si10519077oib.69.2016.12.06.17.11.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 17:11:51 -0800 (PST)
Received: by mail-oi0-x234.google.com with SMTP id w63so400326781oiw.0
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 17:11:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1612051648270.1536@eggly.anvils>
References: <147931721349.37471.4835899844582504197.stgit@dwillia2-desk3.amr.corp.intel.com>
 <alpine.LSU.2.11.1612051648270.1536@eggly.anvils>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 6 Dec 2016 17:11:50 -0800
Message-ID: <CAPcyv4hp03_K1vMsf-=bxuKRYzX=ZMX+bcwnGwLbaoST_JwWjA@mail.gmail.com>
Subject: Re: [PATCH] device-dax: fail all private mapping attempts
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Pawel Lebioda <pawel.lebioda@intel.com>

On Mon, Dec 5, 2016 at 5:01 PM, Hugh Dickins <hughd@google.com> wrote:
> On Wed, 16 Nov 2016, Dan Williams wrote:
>
>> The device-dax implementation originally tried to be tricky and allow
>> private read-only mappings, but in the process allowed writable
>> MAP_PRIVATE + MAP_NORESERVE mappings.  For simplicity and predictability
>> just fail all private mapping attempts since device-dax memory is
>> statically allocated and will never support overcommit.
>>
>> Cc: <stable@vger.kernel.org>
>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>> Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
>> Reported-by: Pawel Lebioda <pawel.lebioda@intel.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  drivers/dax/dax.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/dax/dax.c b/drivers/dax/dax.c
>> index 0e499bfca41c..3d94ff20fdca 100644
>> --- a/drivers/dax/dax.c
>> +++ b/drivers/dax/dax.c
>> @@ -270,8 +270,8 @@ static int check_vma(struct dax_dev *dax_dev, struct vm_area_struct *vma,
>>       if (!dax_dev->alive)
>>               return -ENXIO;
>>
>> -     /* prevent private / writable mappings from being established */
>> -     if ((vma->vm_flags & (VM_NORESERVE|VM_SHARED|VM_WRITE)) == VM_WRITE) {
>> +     /* prevent private mappings from being established */
>> +     if ((vma->vm_flags & VM_SHARED) != VM_SHARED) {
>
> I think that is more restrictive than you intended: haven't tried,
> but I believe it rejects a PROT_READ, MAP_SHARED, O_RDONLY fd mmap,
> leaving no way to mmap /dev/dax without write permission to it.
>
> See line 1393 of mm/mmap.c: the test you want is probably
>         if (!(vma->vm_flags & VM_MAYSHARE))
>

Yes, it is. Thank you!

Fix for the fix on the way...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
