Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id D85346B0253
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 12:40:19 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id bj10so38497058pad.2
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 09:40:19 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id sb2si6988810pac.161.2016.03.04.09.40.19
        for <linux-mm@kvack.org>;
        Fri, 04 Mar 2016 09:40:19 -0800 (PST)
Subject: Re: THP-enabled filesystem vs. FALLOC_FL_PUNCH_HOLE
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160304112603.GA9790@node.shutemov.name>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56D9C882.3040808@intel.com>
Date: Fri, 4 Mar 2016 09:40:18 -0800
MIME-Version: 1.0
In-Reply-To: <20160304112603.GA9790@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/04/2016 03:26 AM, Kirill A. Shutemov wrote:
> On Thu, Mar 03, 2016 at 07:51:50PM +0300, Kirill A. Shutemov wrote:
>> Truncate and punch hole that only cover part of THP range is implemented
>> by zero out this part of THP.
>>
>> This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE) behaviour.
>> As we don't really create hole in this case, lseek(SEEK_HOLE) may have
>> inconsistent results depending what pages happened to be allocated.
>> Not sure if it should be considered ABI break or not.
> 
> Looks like this shouldn't be a problem. man 2 fallocate:
> 
> 	Within the specified range, partial filesystem blocks are zeroed,
> 	and whole filesystem blocks are removed from the file.  After a
> 	successful call, subsequent reads from this range will return
> 	zeroes.
> 
> It means we effectively have 2M filesystem block size.

The question is still whether this will case problems for apps.

Isn't 2MB a quote unusual block size?  Wouldn't some files on a tmpfs
filesystem act like they have a 2M blocksize and others like they have
4k?  Would that confuse apps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
