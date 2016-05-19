Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 829736B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 12:20:07 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gw7so120326217pac.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 09:20:07 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i65si20919249pfb.183.2016.05.19.09.20.06
        for <linux-mm@kvack.org>;
        Thu, 19 May 2016 09:20:06 -0700 (PDT)
Subject: Re: [PATCHv8 26/32] thp: update Documentation/vm/transhuge.txt
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1463067672-134698-27-git-send-email-kirill.shutemov@linux.intel.com>
From: Julien Grall <julien.grall@arm.com>
Message-ID: <573DE7B1.4040303@arm.com>
Date: Thu, 19 May 2016 17:20:01 +0100
MIME-Version: 1.0
In-Reply-To: <1463067672-134698-27-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Steve Capper <Steve.Capper@arm.com>

Hello Kirill,

On 12/05/16 16:41, Kirill A. Shutemov wrote:
> Add info about tmpfs/shmem with huge pages.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>   Documentation/vm/transhuge.txt | 130 +++++++++++++++++++++++++++++------------
>   1 file changed, 93 insertions(+), 37 deletions(-)
>
> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> index d9cb65cf5cfd..96a49f123cac 100644
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -9,8 +9,8 @@ using huge pages for the backing of virtual memory with huge pages
>   that supports the automatic promotion and demotion of page sizes and
>   without the shortcomings of hugetlbfs.
>
> -Currently it only works for anonymous memory mappings but in the
> -future it can expand over the pagecache layer starting with tmpfs.
> +Currently it only works for anonymous memory mappings and tmpfs/shmem.
> +But in the future it can expand to other filesystems.
>
>   The reason applications are running faster is because of two
>   factors. The first factor is almost completely irrelevant and it's not
> @@ -48,7 +48,7 @@ miss is going to run faster.
>   - if some task quits and more hugepages become available (either
>     immediately in the buddy or through the VM), guest physical memory
>     backed by regular pages should be relocated on hugepages
> -  automatically (with khugepaged)
> +  automatically (with khugepaged, limited to anonymous huge pages for now)

Is it still relevant? I think the patch #30 at the support for tmpfs/shmem.

[...]

>   == Need of application restart ==
>
> -The transparent_hugepage/enabled values only affect future
> -behavior. So to make them effective you need to restart any
> -application that could have been using hugepages. This also applies to
> -the regions registered in khugepaged.
> +The transparent_hugepage/enabled values and tmpfs mount option only affect
> +future behavior. So to make them effective you need to restart any
> +application that could have been using hugepages. This also applies to the
> +regions registered in khugepaged.
>
>   == Monitoring usage ==
>
> -The number of transparent huge pages currently used by the system is
> -available by reading the AnonHugePages field in /proc/meminfo. To
> -identify what applications are using transparent huge pages, it is
> -necessary to read /proc/PID/smaps and count the AnonHugePages fields
> -for each mapping. Note that reading the smaps file is expensive and
> -reading it frequently will incur overhead.
> +The number of anonymous transparent huge pages currently used by the
> +system is available by reading the AnonHugePages field in /proc/meminfo.
> +To identify what applications are using anonymous transparent huge pages,
> +it is necessary to read /proc/PID/smaps and count the AnonHugePages fields
> +for each mapping.
> +
> +The number of file transparent huge pages mapped to userspace is available
> +by reading the FileHugeMapped field in /proc/meminfo.  To identify what
> +applications are mapping file  transparent huge pages, it is necessary
> +to read /proc/PID/smaps and count the FileHugeMapped fields for each
> +mapping.

I cannot find the field FileHugeMapped in /proc/meminfo and 
/proc/PID/smaps. However, there are 2 new fields ShmemHugePages and 
ShmemPmdMapped.

Also I guess that filesystems/proc.txt has to be updated to explain the 
new fields.

Regards,

-- 
Julien Grall

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
