Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5B56B0036
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:51:14 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kx10so3636486pab.21
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:51:14 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id k3si7960873pbb.264.2014.01.30.13.51.13
        for <linux-mm@kvack.org>;
        Thu, 30 Jan 2014 13:51:13 -0800 (PST)
Date: Thu, 30 Jan 2014 13:51:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 1/2] mm: add kstrimdup function
Message-Id: <20140130135111.cffc7d8852dd38545bddeb75@linux-foundation.org>
In-Reply-To: <20140130214545.18296.69349@capellas-linux>
References: <1391116318-17253-1-git-send-email-sebastian.capella@linaro.org>
	<1391116318-17253-2-git-send-email-sebastian.capella@linaro.org>
	<20140130132251.4f662aeddc09d8410dee4490@linux-foundation.org>
	<20140130214545.18296.69349@capellas-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Joe Perches <joe@perches.com>, Mikulas Patocka <mpatocka@redhat.com>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, 30 Jan 2014 13:45:45 -0800 Sebastian Capella <sebastian.capella@linaro.org> wrote:

> Quoting Andrew Morton (2014-01-30 13:22:51)
> > On Thu, 30 Jan 2014 13:11:57 -0800 Sebastian Capella <sebastian.capella@linaro.org> wrote:
> > > +char *kstrimdup(const char *s, gfp_t gfp)
> > > +{
> > > +     char *buf;
> > > +     char *begin = skip_spaces(s);
> > > +     size_t len = strlen(begin);
> > > +
> > > +     while (len > 1 && isspace(begin[len - 1]))
> > > +             len--;
> > 
> > That's off-by-one isn't it?  kstrimdup("   ") should return "", not " ".
> > 
> > > +     buf = kmalloc_track_caller(len + 1, gfp);
> > > +     if (!buf)
> > > +             return NULL;
> > > +
> > > +     memcpy(buf, begin, len);
> > > +     buf[len] = '\0';
> > > +
> > > +     return buf;
> > > +}
> 
> Hi Andrew,
> 
> I think this is a little tricky.
> 
> For an empty string, the function relies on skip_spaces to point begin
> at the \0'.
> 
> Alternately, if we don't have an empty string, we know we have at least 1
> non-space, non-null character at begin[0], and there's no need to check it,
> so the loop stops at [1].  If there's a space at 1, we just put the '\0'
> there.
> 
> We could check at [0], but I think its already been checked by skip_spaces.

heh, OK, tricky.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
