Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C3D7A6B0038
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 20:44:56 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so58923682pdr.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 17:44:56 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id qy4si43467pbb.0.2015.08.10.17.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 17:44:55 -0700 (PDT)
Received: by pdrh1 with SMTP id h1so58923556pdr.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 17:44:55 -0700 (PDT)
Date: Mon, 10 Aug 2015 17:44:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 3/3] Documentation/filesystems/proc.txt: document
 hugetlb RSS
In-Reply-To: <1439167624-17772-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.10.1508101741020.28691@chino.kir.corp.google.com>
References: <20150807155537.d483456f753355059f9ce10a@linux-foundation.org> <1439167624-17772-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1439167624-17772-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, 10 Aug 2015, Naoya Horiguchi wrote:

> diff --git v4.2-rc4.orig/Documentation/filesystems/proc.txt v4.2-rc4/Documentation/filesystems/proc.txt
> index 6f7fafde0884..cb8565e150ed 100644
> --- v4.2-rc4.orig/Documentation/filesystems/proc.txt
> +++ v4.2-rc4/Documentation/filesystems/proc.txt
> @@ -168,6 +168,7 @@ For example, to get the status information of a process, all you have to do is
>    VmLck:         0 kB
>    VmHWM:       476 kB
>    VmRSS:       476 kB
> +  VmHugetlbRSS:  0 kB
>    VmData:      156 kB
>    VmStk:        88 kB
>    VmExe:        68 kB
> @@ -230,6 +231,7 @@ Table 1-2: Contents of the status files (as of 4.1)
>   VmLck                       locked memory size
>   VmHWM                       peak resident set size ("high water mark")
>   VmRSS                       size of memory portions
> + VmHugetlbRSS                size of hugetlb memory portions
>   VmData                      size of data, stack, and text segments
>   VmStk                       size of data, stack, and text segments
>   VmExe                       size of text segment
> @@ -440,8 +442,12 @@ indicates the amount of memory currently marked as referenced or accessed.
>  "Anonymous" shows the amount of memory that does not belong to any file.  Even
>  a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
>  and a page is modified, the file page is replaced by a private anonymous copy.
> -"Swap" shows how much would-be-anonymous memory is also used, but out on
> -swap.
> +"Swap" shows how much would-be-anonymous memory is also used, but out on swap.
> +Since 4.3, "RSS" contains the amount of mappings for hugetlb pages. Although
> +RSS of hugetlb mappings is maintained separately from normal mappings
> +(displayed in "VmHugetlbRSS" field of /proc/PID/status,) /proc/PID/smaps shows
> +both mappings in "RSS" field. Userspace applications clearly distinguish the
> +type of mapping with 'ht' flag in "VmFlags" field.
>  
>  "VmFlags" field deserves a separate description. This member represents the kernel
>  flags associated with the particular virtual memory area in two letter encoded

My objection to adding hugetlb memory to the RSS field of /proc/pid/smaps 
still stands and can be addressed in the thread of the first patch.  Since 
this includes wording that describes that change, then the objection would 
also cover that.

With regard to adding VmHugetlbRSS, I think the change is fine, and I 
appreciate that you call it VmHugetlbRSS and not VmHugeRSS since that 
would be confused with thp.

My only concern regarding VmHugetlbRSS would be extendability and whether 
we will eventually, or even today, want to differentiate between various 
hugetlb page sizes.  For example, if 1GB hugetlb pages on x86 are a 
precious resource, then how do I determine which process has mapped it 
rather than 512 2MB hugetlb pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
