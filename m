Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B1B116B0390
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:03:13 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v6so5192942wrc.21
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 23:03:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 94si34517449wrj.209.2017.04.12.23.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 23:03:12 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D5wuRJ046108
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:03:11 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29t26c2y7n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:03:10 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 13 Apr 2017 16:03:08 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D62vZr53018688
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 16:03:05 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D62WdZ015572
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 16:02:33 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
In-Reply-To: <20170328175408.GD7838@bombadil.infradead.org>
References: <1488992761-9464-1-git-send-email-dave@stgolabs.net> <20170328165343.GB27446@linux-80c1.suse> <20170328165513.GC27446@linux-80c1.suse> <20170328175408.GD7838@bombadil.infradead.org>
Date: Thu, 13 Apr 2017 11:32:09 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87wpaoq1zy.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, mhocko@suse.com, ak@linux.intel.com, mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com

Matthew Wilcox <willy@infradead.org> writes:

> On Tue, Mar 28, 2017 at 09:55:13AM -0700, Davidlohr Bueso wrote:
>> Do we have any consensus here? Keeping SHM_HUGE_* is currently
>> winning 2-1. If there are in fact users out there computing the
>> value manually, then I am ok with keeping it and properly exporting
>> it. Michal?
>
> Well, let's see what it looks like to do that.  I went down the rabbit
> hole trying to understand why some of the SHM_ flags had the same value
> as each other until I realised some of them were internal flags, some
> were flags to shmat() and others were flags to shmget().  Hopefully I
> disambiguated them nicely in this patch.  I also added 8MB and 16GB sizes.
> Any more architectures with a pet favourite huge/giant page size we
> should add convenience defines for?
>
> diff --git a/include/linux/shm.h b/include/linux/shm.h
> index 04e881829625..cd95243efd1a 100644
> --- a/include/linux/shm.h
> +++ b/include/linux/shm.h
> @@ -24,26 +24,13 @@ struct shmid_kernel /* private to the kernel */
>  	struct list_head	shm_clist;	/* list by creator */
>  };
>  
> -/* shm_mode upper byte flags */
> -#define	SHM_DEST	01000	/* segment will be destroyed on last detach */
> -#define SHM_LOCKED      02000   /* segment will not be swapped */
> -#define SHM_HUGETLB     04000   /* segment will use huge TLB pages */
> -#define SHM_NORESERVE   010000  /* don't check for reservations */
> -
> -/* Bits [26:31] are reserved */
> -
>  /*
> - * When SHM_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
> - * This gives us 6 bits, which is enough until someone invents 128 bit address
> - * spaces.
> - *
> - * Assume these are all power of twos.
> - * When 0 use the default page size.
> + * These flags are used internally; they cannot be specified by the user.
> + * They are masked off in newseg().  These values are used by IPC_CREAT
> + * and IPC_EXCL when calling shmget().
>   */
> -#define SHM_HUGE_SHIFT  26
> -#define SHM_HUGE_MASK   0x3f
> -#define SHM_HUGE_2MB    (21 << SHM_HUGE_SHIFT)
> -#define SHM_HUGE_1GB    (30 << SHM_HUGE_SHIFT)
> +#define	SHM_DEST	01000	/* segment will be destroyed on last detach */
> +#define SHM_LOCKED      02000   /* segment will not be swapped */
>  
>  #ifdef CONFIG_SYSVIPC
>  struct sysv_shm {
> diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
> index 1fbf24ea37fd..44b36cb228d7 100644
> --- a/include/uapi/linux/shm.h
> +++ b/include/uapi/linux/shm.h
> @@ -40,15 +40,34 @@ struct shmid_ds {
>  /* Include the definition of shmid64_ds and shminfo64 */
>  #include <asm/shmbuf.h>
>  
> -/* permission flag for shmget */
> +/* shmget() shmflg values. */
> +/* The bottom nine bits are the same as open(2) mode flags */
>  #define SHM_R		0400	/* or S_IRUGO from <linux/stat.h> */
>  #define SHM_W		0200	/* or S_IWUGO from <linux/stat.h> */
> +/* Bits 9 & 10 are IPC_CREAT and IPC_EXCL */
> +#define SHM_HUGETLB     (1 << 11) /* segment will use huge TLB pages */
> +#define SHM_NORESERVE   (1 << 12) /* don't check for reservations */
>  
> -/* mode for attach */
> -#define	SHM_RDONLY	010000	/* read-only access */
> -#define	SHM_RND		020000	/* round attach address to SHMLBA boundary */
> -#define	SHM_REMAP	040000	/* take-over region on attach */
> -#define	SHM_EXEC	0100000	/* execution access */
> +/*
> + * When SHM_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
> + * This gives us 6 bits, which is enough until someone invents 128 bit address
> + * spaces.  These match MAP_HUGE_SHIFT and MAP_HUGE_MASK.
> + *
> + * Assume these are all powers of two.
> + * When 0 use the default page size.
> + */
> +#define SHM_HUGE_SHIFT	26
> +#define SHM_HUGE_MASK	0x3f
> +#define SHM_HUGE_2MB	(21 << SHM_HUGE_SHIFT)
> +#define SHM_HUGE_8MB	(23 << SHM_HUGE_SHIFT)
> +#define SHM_HUGE_1GB	(30 << SHM_HUGE_SHIFT)
> +#define SHM_HUGE_16GB	(34 << SHM_HUGE_SHIFT)


This should be in arch/uapi like MAP_HUGE_2M ? That will let arch add
#defines based on the hugepae size supported by them.

> +
> +/* shmat() shmflg values */
> +#define	SHM_RDONLY	(1 << 12) /* read-only access */
> +#define	SHM_RND		(1 << 13) /* round attach address to SHMLBA boundary */
> +#define	SHM_REMAP	(1 << 14) /* take-over region on attach */
> +#define	SHM_EXEC	(1 << 15) /* execution access */
>  

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
