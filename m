Date: Fri, 28 Feb 2003 09:56:34 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: Rising io_load results Re: 2.5.63-mm1
Message-ID: <3050000.1046447794@baldur.austin.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0302281245170.1203-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0302281245170.1203-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@digeo.com>
Cc: Con Kolivas <kernel@kolivas.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Friday, February 28, 2003 12:48:06 +0000 Hugh Dickins
<hugh@veritas.com> wrote:

> On Thu, 27 Feb 2003, Andrew Morton wrote:
>> 
>> No, it is still wrong.  Mapped cannot exceed MemTotal.
> 
> It needs this in addition to Dave's patch from yesterday:
> 
> --- 2.5.63-objfix-1/mm/rmap.c	Thu Feb 27 23:37:28 2003
> +++ 2.5.63-objfix-2/mm/rmap.c	Fri Feb 28 12:33:58 2003
> @@ -349,7 +349,8 @@
>  			BUG();
>  		if (atomic_read(&page->pte.mapcount) == 0)
>  			BUG();
> -		atomic_dec(&page->pte.mapcount);
> +		if (atomic_dec_and_test(&page->pte.mapcount))
> +			dec_page_state(nr_mapped);
>  		return;
>  	}

D'oh.  I should have seen that one.  Thanks.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
