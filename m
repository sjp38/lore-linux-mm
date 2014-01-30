Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0ADCD6B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 22:51:06 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id uq10so16863639igb.2
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 19:51:05 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0102.hostedemail.com. [216.40.44.102])
        by mx.google.com with ESMTP id mg9si6414497icc.115.2014.01.29.19.51.05
        for <linux-mm@kvack.org>;
        Wed, 29 Jan 2014 19:51:05 -0800 (PST)
Message-ID: <1391053859.2422.34.camel@joe-AO722>
Subject: Re: [PATCH v4 1/2] mm: add kstrimdup function
From: Joe Perches <joe@perches.com>
Date: Wed, 29 Jan 2014 19:50:59 -0800
In-Reply-To: <20140130034137.2769.50210@capellas-linux>
References: <1391039304-3172-1-git-send-email-sebastian.capella@linaro.org>
	 <1391039304-3172-2-git-send-email-sebastian.capella@linaro.org>
	 <alpine.LRH.2.02.1401291956510.8304@file01.intranet.prod.int.rdu2.redhat.com>
	 <1391045068.2422.30.camel@joe-AO722>
	 <20140130034137.2769.50210@capellas-linux>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 2014-01-29 at 19:41 -0800, Sebastian Capella wrote:
> Quoting Joe Perches (2014-01-29 17:24:28)
> > Why not minimize the malloc length too?
> > 

> I figured it would be mostly for small trimming, but it seems like
> it could be and advantage and used more generally this way.
> 
> I have a couple of small changes to return NULL in empty string/all ws
> cases and fix a buffer underrun.
> 
> How does this look?
[]
> char *kstrimdup(const char *s, gfp_t gfp)
> {                                                                                
>         char *buf;                                                               
>         const char *begin = skip_spaces(s);                                      
>         size_t len = strlen(begin);                                              

removing begin and just using s would work

>         if (len == 0)                                                            
>                 return NULL;                                                     
>                                                                                  
>         while (len > 1 && isspace(begin[len - 1]))                               
>                 len--;                                                           
>                                                                                  
>         buf = kmalloc_track_caller(len + 1, gfp);                                
>         if (!buf)                                                                
>                 return NULL;                                                     
>                                                                                  
>         memcpy(buf, begin, len);                                                 
>         buf[len] = '\0';                                                            
>                                                                                  
>         return buf;                                                              
> }

What should the return be to this string?

" "

Should it be "" or " " or NULL?

I don't think it should be NULL.
I don't think it should be " ".

cheers, Joe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
