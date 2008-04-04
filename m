From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC PATCH 2/2] futex: use fast_gup()
Date: Fri, 04 Apr 2008 21:47:17 +0200
Message-ID: <1207338437.29991.11.camel@lappy>
References: <20080404193332.348493000@chello.nl>
	 <20080404193817.830004000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760709AbYDDTrq@vger.kernel.org>
In-Reply-To: <20080404193817.830004000@chello.nl>
Sender: linux-kernel-owner@vger.kernel.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Fri, 2008-04-04 at 21:33 +0200, Peter Zijlstra wrote:

> @@ -217,7 +199,7 @@ static int get_futex_key(u32 __user *uad
>  		return 0;
>  	}
>  
> -	err = get_user_pages(current, mm, address, 1, 0, 0, &page, NULL);
> +	err = fast_gup(address, 1, 0, &page);
>  	if (err < 0)
>  		return err;
>  


Failed to include the following hunk...

Index: linux-2.6/kernel/futex.c
===================================================================
--- linux-2.6.orig/kernel/futex.c
+++ linux-2.6/kernel/futex.c
@@ -203,6 +203,9 @@ static int get_futex_key(u32 __user *uad
 	if (err < 0)
 		return err;
 
+	if (!page)
+		return -EFAULT;
+
 	key->shared.page = page;
 	key->both.offset |= FUT_OFF_PAGE;
 
