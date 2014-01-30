Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8A06B0036
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:45:49 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so3645827pbb.39
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:45:48 -0800 (PST)
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
        by mx.google.com with ESMTPS id ln7si7950874pab.207.2014.01.30.13.45.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 13:45:48 -0800 (PST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so3651901pbb.9
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:45:48 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Sebastian Capella <sebastian.capella@linaro.org>
In-Reply-To: <20140130132251.4f662aeddc09d8410dee4490@linux-foundation.org>
References: <1391116318-17253-1-git-send-email-sebastian.capella@linaro.org>
 <1391116318-17253-2-git-send-email-sebastian.capella@linaro.org>
 <20140130132251.4f662aeddc09d8410dee4490@linux-foundation.org>
Message-ID: <20140130214545.18296.69349@capellas-linux>
Subject: Re: [PATCH v5 1/2] mm: add kstrimdup function
Date: Thu, 30 Jan 2014 13:45:45 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Joe Perches <joe@perches.com>, Mikulas Patocka <mpatocka@redhat.com>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Quoting Andrew Morton (2014-01-30 13:22:51)
> On Thu, 30 Jan 2014 13:11:57 -0800 Sebastian Capella <sebastian.capella@l=
inaro.org> wrote:
> > +char *kstrimdup(const char *s, gfp_t gfp)
> > +{
> > +     char *buf;
> > +     char *begin =3D skip_spaces(s);
> > +     size_t len =3D strlen(begin);
> > +
> > +     while (len > 1 && isspace(begin[len - 1]))
> > +             len--;
> =

> That's off-by-one isn't it?  kstrimdup("   ") should return "", not " ".
> =

> > +     buf =3D kmalloc_track_caller(len + 1, gfp);
> > +     if (!buf)
> > +             return NULL;
> > +
> > +     memcpy(buf, begin, len);
> > +     buf[len] =3D '\0';
> > +
> > +     return buf;
> > +}

Hi Andrew,

I think this is a little tricky.

For an empty string, the function relies on skip_spaces to point begin
at the \0'.

Alternately, if we don't have an empty string, we know we have at least 1
non-space, non-null character at begin[0], and there's no need to check it,
so the loop stops at [1].  If there's a space at 1, we just put the '\0'
there.

We could check at [0], but I think its already been checked by skip_spaces.

I'll add a comment above the while for that

Thanks,

Sebastian


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
