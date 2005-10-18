Received: by zproxy.gmail.com with SMTP id k1so232376nzf
        for <linux-mm@kvack.org>; Tue, 18 Oct 2005 03:05:04 -0700 (PDT)
Message-ID: <aec7e5c30510180305q43488fcdq601045baa6ecb409@mail.gmail.com>
Date: Tue, 18 Oct 2005 19:05:03 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 2/2] Page migration via Swap V2: MPOL_MF_MOVE interface
In-Reply-To: <20051018004942.3191.44835.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
	 <20051018004942.3191.44835.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, ak@suse.de, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi again,

On 10/18/05, Christoph Lameter <clameter@sgi.com> wrote:
> +       vma = check_range(mm, start, end, nmask, flags,
> +                         (flags & MPOL_MF_MOVE) ? &pagelist : NULL);
>         err = PTR_ERR(vma);
> -       if (!IS_ERR(vma))
> +       if (!IS_ERR(vma)) {
>                 err = mbind_range(vma, start, end, new);
> +               if (!list_empty(&pagelist))
> +                       swapout_pages(&pagelist);
> +               if (!err  && !list_empty(&pagelist) && (flags & MPOL_MF_STRICT))
> +                               err = -EIO;
> +       }
> +       if (!list_empty(&pagelist))
> +               putback_lru_pages(&pagelist);

isolate_lru_page() calls get_page_testone(), and swapout_pages() seems
to call __put_page(). But who decrements page->_count in the case of
putback_lru_pages()?

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
