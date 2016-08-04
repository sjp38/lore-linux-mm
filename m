Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CAC56B025E
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 08:19:12 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n69so510984580ion.0
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 05:19:12 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s17si4035593oih.89.2016.08.04.05.19.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Aug 2016 05:19:11 -0700 (PDT)
Subject: Re: [PATCH] fs:Fix kmemleak leak warning in getname_flags about
 working on unitialized memory
References: <1470260896-31767-1-git-send-email-xerofoify@gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <df8dd6cd-245d-0673-0246-e514b2a67fc2@I-love.SAKURA.ne.jp>
Date: Thu, 4 Aug 2016 21:18:19 +0900
MIME-Version: 1.0
In-Reply-To: <1470260896-31767-1-git-send-email-xerofoify@gmail.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Krause <xerofoify@gmail.com>, viro@zeniv.linux.org.uk
Cc: akpm@linux-foundation.org, msalter@redhat.com, kuleshovmail@gmail.com, david.vrabel@citrix.com, vbabka@suse.cz, ard.biesheuvel@linaro.org, jgross@suse.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2016/08/04 6:48, Nicholas Krause wrote:
> This fixes a kmemleak leak warning complaining about working on
> unitializied memory as found in the function, getname_flages. Seems
> that we are indeed working on unitialized memory, as the filename
> char pointer is never made to point to the filname structure's result
> member for holding it's name, fix this by using memcpy to copy the
> filname structure pointer's, name to the char pointer passed to this
> function.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  fs/namei.c         | 1 +
>  mm/early_ioremap.c | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index c386a32..6b18d57 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -196,6 +196,7 @@ getname_flags(const char __user *filename, int flags, int *empty)
>  		}
>  	}
>  
> +	memcpy((char *)result->name, filename, len);

This filename is a __user pointer. Reading with memcpy() is not safe.

>  	result->uptr = filename;
>  	result->aname = NULL;
>  	audit_getname(result);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
