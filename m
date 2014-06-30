Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3641C6B0036
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 19:06:07 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so8968056pdb.7
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 16:06:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ra4si24781038pbb.78.2014.06.30.16.06.06
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 16:06:06 -0700 (PDT)
Date: Mon, 30 Jun 2014 16:06:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] binfmt_elf.c: use get_random_int() to fix entropy
 depleting fix
Message-Id: <20140630160604.c43af52d134f3cd8034518c5@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1406301549020.23648@chino.kir.corp.google.com>
References: <53aa90d2.Yd3WgTmElIsuiwuV%fengguang.wu@intel.com>
	<20140625100213.GA1866@localhost>
	<53AAB2D3.2050809@oracle.com>
	<alpine.DEB.2.02.1406251543080.4592@chino.kir.corp.google.com>
	<53AB7F0B.5050900@oracle.com>
	<alpine.DEB.2.02.1406252310560.3960@chino.kir.corp.google.com>
	<53ABBEA0.1010307@oracle.com>
	<20140626074735.GA24582@localhost>
	<alpine.DEB.2.02.1406301549020.23648@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jeff Liu <jeff.liu@oracle.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org

On Mon, 30 Jun 2014 15:52:05 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> The type of size_t on am33 is unsigned int for gcc major versions >= 4.
> 
> ...
>
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -155,7 +155,7 @@ static void get_atrandom_bytes(unsigned char *buf, size_t nbytes)
>  
>  	while (nbytes) {
>  		unsigned int random_variable;
> -		size_t chunk = min(nbytes, sizeof(random_variable));
> +		size_t chunk = min(nbytes, (size_t)sizeof(random_variable));
>  
>  		random_variable = get_random_int();
>  		memcpy(p, &random_variable, chunk);

I did it using min_t the other day.  I suppose using the cast is a
little clearer about the cause of the problem, but if it doesn't have a
code comment the janitors will come along and convert it to min_t.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
