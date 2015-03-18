Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE4E6B006C
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 17:41:10 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so54803494pdb.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 14:41:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cn14si38468952pac.39.2015.03.18.14.41.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 14:41:09 -0700 (PDT)
Date: Wed, 18 Mar 2015 14:41:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 4/4] hugetlbfs: document min_size mount option
Message-Id: <20150318144108.e235862e0be30ff626e01820@linux-foundation.org>
In-Reply-To: <3c82f2203e5453ddf3b29431863034afc7699303.1426549011.git.mike.kravetz@oracle.com>
References: <cover.1426549010.git.mike.kravetz@oracle.com>
	<3c82f2203e5453ddf3b29431863034afc7699303.1426549011.git.mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 16 Mar 2015 16:53:29 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Update documentation for the hugetlbfs min_size mount option.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  Documentation/vm/hugetlbpage.txt | 21 ++++++++++++++-------
>  1 file changed, 14 insertions(+), 7 deletions(-)
> 
> diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
> index f2d3a10..83c0305 100644
> --- a/Documentation/vm/hugetlbpage.txt
> +++ b/Documentation/vm/hugetlbpage.txt
> @@ -267,8 +267,8 @@ call, then it is required that system administrator mount a file system of
>  type hugetlbfs:
>  
>    mount -t hugetlbfs \
> -	-o uid=<value>,gid=<value>,mode=<value>,size=<value>,nr_inodes=<value> \
> -	none /mnt/huge
> +	-o uid=<value>,gid=<value>,mode=<value>,size=<value>,min_size=<value>, \
> +	nr_inodes=<value> none /mnt/huge
>  
>  This command mounts a (pseudo) filesystem of type hugetlbfs on the directory
>  /mnt/huge.  Any files created on /mnt/huge uses huge pages.  The uid and gid
> @@ -277,11 +277,18 @@ the uid and gid of the current process are taken.  The mode option sets the
>  mode of root of file system to value & 01777.  This value is given in octal.
>  By default the value 0755 is picked. The size option sets the maximum value of
>  memory (huge pages) allowed for that filesystem (/mnt/huge). The size is
> -rounded down to HPAGE_SIZE.  The option nr_inodes sets the maximum number of
> -inodes that /mnt/huge can use.  If the size or nr_inodes option is not
> -provided on command line then no limits are set.  For size and nr_inodes
> -options, you can use [G|g]/[M|m]/[K|k] to represent giga/mega/kilo. For
> -example, size=2K has the same meaning as size=2048.
> +rounded down to HPAGE_SIZE.  The min_size option sets the minimum value of
> +memory (huge pages) allowed for the filesystem.  Like the size option,
> +min_size is rounded down to HPAGE_SIZE.  At mount time, the number of huge
> +pages specified by min_size are reserved for use by the filesystem.  If
> +there are not enough free huge pages available, the mount will fail.  As
> +huge pages are allocated to the filesystem and freed, the reserve count
> +is adjusted so that the sum of allocated and reserved huge pages is always
> +at least min_size.  The option nr_inodes sets the maximum number of
> +inodes that /mnt/huge can use.  If the size, min_size or nr_inodes option
> +is not provided on command line then no limits are set.  For size, min_size
> +and nr_inodes options, you can use [G|g]/[M|m]/[K|k] to represent
> +giga/mega/kilo. For example, size=2K has the same meaning as size=2048.

Nowhere here is the reader told the units of "size".  We should at
least describe that, and maybe even rename the thing to min_bytes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
