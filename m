Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD14C6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 12:33:58 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t184so11466149qke.0
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 09:33:58 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u184si6113895qkd.263.2017.09.25.09.33.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 09:33:57 -0700 (PDT)
Subject: Re: [patch v2] mremap.2: Add description of old_size == 0
 functionality
References: <a5d279cb-a015-f74c-2e40-a231aa7f7a8c@redhat.com>
 <20170919214224.19561-1-mike.kravetz@oracle.com>
 <6fafdae8-4fea-c967-f5cd-d22c205608fa@gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <83b023da-e9f5-2957-981e-5b0e71e9bf1b@oracle.com>
Date: Mon, 25 Sep 2017 09:33:52 -0700
MIME-Version: 1.0
In-Reply-To: <6fafdae8-4fea-c967-f5cd-d22c205608fa@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: linux-man@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Jann Horn <jannh@google.com>, Florian Weimer <fweimer@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On 09/20/2017 12:25 AM, Michael Kerrisk (man-pages) wrote:
> Hello Mike,
> 
> On 09/19/2017 11:42 PM, Mike Kravetz wrote:
>> v2: Fix incorrect wording noticed by Jann Horn.
>>     Remove deprecated and memfd_create discussion as suggested
>>     by Florian Weimer.
>>
>> Since at least the 2.6 time frame, mremap would create a new mapping
>> of the same pages if 'old_size == 0'.  It would also leave the original
>> mapping.  This was used to create a 'duplicate mapping'.
>>
>> A recent change was made to mremap so that an attempt to create a
>> duplicate a private mapping will fail.
>>
>> Document the 'old_size == 0' behavior and new return code from
>> below commit.
>>
>> commit dba58d3b8c5045ad89c1c95d33d01451e3964db7
>> Author: Mike Kravetz <mike.kravetz@oracle.com>
>> Date:   Wed Sep 6 16:20:55 2017 -0700
>>
>>     mm/mremap: fail map duplication attempts for private mappings
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>  man2/mremap.2 | 21 ++++++++++++++++++++-
>>  1 file changed, 20 insertions(+), 1 deletion(-)
>>
>> diff --git a/man2/mremap.2 b/man2/mremap.2
>> index 98643c640..235984a96 100644
>> --- a/man2/mremap.2
>> +++ b/man2/mremap.2
>> @@ -58,6 +58,20 @@ may be provided; see the description of
>>  .B MREMAP_FIXED
>>  below.
>>  .PP
>> +If the value of \fIold_size\fP is zero, and \fIold_address\fP refers to
>> +a shareable mapping (see
>> +.BR mmap (2)
>> +.BR MAP_SHARED )
>> +, then
>> +.BR mremap ()
>> +will create a new mapping of the same pages. \fInew_size\fP
>> +will be the size of the new mapping and the location of the new mapping
>> +may be specified with \fInew_address\fP, see the description of
>> +.B MREMAP_FIXED
>> +below.  If a new mapping is requested via this method, then the
>> +.B MREMAP_MAYMOVE
>> +flag must also be specified.
>> +.PP
>>  In Linux the memory is divided into pages.
>>  A user process has (one or)
>>  several linear virtual memory segments.
>> @@ -174,7 +188,12 @@ and
>>  or
>>  .B MREMAP_FIXED
>>  was specified without also specifying
>> -.BR MREMAP_MAYMOVE .
>> +.BR MREMAP_MAYMOVE ;
>> +or \fIold_size\fP was zero and \fIold_address\fP does not refer to a
>> +shareable mapping;
>> +or \fIold_size\fP was zero and the
>> +.BR MREMAP_MAYMOVE
>> +flag was not specified.
>>  .TP
>>  .B ENOMEM
>>  The memory area cannot be expanded at the current virtual address, and the
> 
> I've applied this, and added Reviewed-by tags for Florian and Jann.
> But, I think it's also worth noting the older, now disallowed, behavior,
> and why the behavior was changed. So I added a note in BUGS:
> 
>     BUGS
>        Before Linux 4.14, if old_size was zero and the  mapping  referred
>        to  by  old_address  was  a private mapping (mmap(2) MAP_PRIVATE),
>        mremap() created a new private mapping unrelated to  the  original
>        mapping.   This behavior was unintended and probably unexpected in
>        user-space applications (since the intention  of  mremap()  is  to
>        create  a new mapping based on the original mapping).  Since Linux
>        4.14, mremap() fails with the error EINVAL in this scenario.
> 
> Does that seem okay?

Sorry for the late reply Michael,  I've been away for a few days.

Yes, the above seems okay.  Thanks for your help with this.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
