Received: by rv-out-0910.google.com with SMTP id l15so310344rvb
        for <linux-mm@kvack.org>; Wed, 24 Oct 2007 22:37:26 -0700 (PDT)
Message-ID: <84144f020710242237q3aa8e96dtc8cf3f02f2af2cc9@mail.gmail.com>
Date: Thu, 25 Oct 2007 08:37:26 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH+comment] fix tmpfs BUG and AOP_WRITEPAGE_ACTIVATE
In-Reply-To: <Pine.LNX.4.64.0710242233470.17796@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>
	 <200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
	 <84144f020710150447o94b1babo8b6e6a647828465f@mail.gmail.com>
	 <Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0710242152020.13001@blonde.wat.veritas.com>
	 <20071024140836.a0098180.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0710242233470.17796@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ezk@cs.sunysb.edu, ryan@finnie.org, mhalcrow@us.ibm.com, cjwatson@ubuntu.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On 10/25/07, Hugh Dickins <hugh@veritas.com> wrote:
> --- 2.6.24-rc1/mm/shmem.c       2007-10-24 07:16:04.000000000 +0100
> +++ linux/mm/shmem.c    2007-10-24 22:31:09.000000000 +0100
> @@ -915,6 +915,21 @@ static int shmem_writepage(struct page *
>         struct inode *inode;
>
>         BUG_ON(!PageLocked(page));
> +       /*
> +        * shmem_backing_dev_info's capabilities prevent regular writeback or
> +        * sync from ever calling shmem_writepage; but a stacking filesystem
> +        * may use the ->writepage of its underlying filesystem, in which case

I find the above bit somewhat misleading as it implies that the
!wbc->for_reclaim case can be removed after ecryptfs has similar fix
as unionfs. Can we just say that while BDI_CAP_NO_WRITEBACK does
prevent some callers from entering ->writepage(), it's just an
optimization and ->writepage() must deal with !wbc->for_reclaim case
properly?

                                          Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
