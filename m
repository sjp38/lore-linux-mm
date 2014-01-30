Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B04076B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 22:41:45 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kx10so2595952pab.21
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 19:41:45 -0800 (PST)
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
        by mx.google.com with ESMTPS id zk9si4743089pac.260.2014.01.29.19.41.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 19:41:44 -0800 (PST)
Received: by mail-pb0-f41.google.com with SMTP id up15so2626520pbc.28
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 19:41:43 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Sebastian Capella <sebastian.capella@linaro.org>
In-Reply-To: <1391045068.2422.30.camel@joe-AO722>
References: <1391039304-3172-1-git-send-email-sebastian.capella@linaro.org>
 <1391039304-3172-2-git-send-email-sebastian.capella@linaro.org>
 <alpine.LRH.2.02.1401291956510.8304@file01.intranet.prod.int.rdu2.redhat.com>
 <1391045068.2422.30.camel@joe-AO722>
Message-ID: <20140130034137.2769.50210@capellas-linux>
Subject: Re: [PATCH v4 1/2] mm: add kstrimdup function
Date: Wed, 29 Jan 2014 19:41:37 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>, Mikulas Patocka <mpatocka@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Quoting Joe Perches (2014-01-29 17:24:28)
> Why not minimize the malloc length too?
> =

> maybe something like:
> =

> char *kstrimdup(const char *s, gfp_t gfp)
> {
>         char *buf;
>         const char *begin =3D skip_spaces(s);
>         size_t len =3D strlen(begin);
> =

>         while (len && isspace(begin[len - 1]))
>                 len--;
> =

>         buf =3D kmalloc_track_caller(len + 1, gfp);
>         if (!buf)
>                 return NULL;
> =

>         memcpy(buf, begin, len);
>         buf[len] =3D 0;
> =

>         return buf;
> }

I figured it would be mostly for small trimming, but it seems like
it could be and advantage and used more generally this way.

I have a couple of small changes to return NULL in empty string/all ws
cases and fix a buffer underrun.

How does this look?

Thanks,

Sebastian


char *kstrimdup(const char *s, gfp_t gfp)
{                                                                          =
      =

        char *buf;                                                         =
      =

        const char *begin =3D skip_spaces(s);                              =
        =

        size_t len =3D strlen(begin);                                      =
        =


        if (len =3D=3D 0)                                                  =
          =

                return NULL;                                               =
      =

                                                                           =
      =

        while (len > 1 && isspace(begin[len - 1]))                         =
      =

                len--;                                                     =
      =

                                                                           =
      =

        buf =3D kmalloc_track_caller(len + 1, gfp);                        =
        =

        if (!buf)                                                          =
      =

                return NULL;                                               =
      =

                                                                           =
      =

        memcpy(buf, begin, len);                                           =
      =

        buf[len] =3D '\0';                                                 =
           =

                                                                           =
      =

        return buf;                                                        =
      =

}        =




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
