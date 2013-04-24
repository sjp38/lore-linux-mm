Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id A0E166B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 07:11:43 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so1069585pdj.20
        for <linux-mm@kvack.org>; Wed, 24 Apr 2013 04:11:42 -0700 (PDT)
Date: Wed, 24 Apr 2013 19:29:04 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: [PATCH v3 17/18] ext4: make punch hole code path work with
 bigalloc
Message-ID: <20130424112904.GA3128@gmail.com>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
 <1365498867-27782-18-git-send-email-lczerner@redhat.com>
 <20130420134241.GA2461@quack.suse.cz>
 <20130423091928.GA5321@gmail.com>
 <alpine.LFD.2.00.1304241303560.24669@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LFD.2.00.1304241303560.24669@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?THVrw6HFoQ==?= Czerner <lczerner@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Wed, Apr 24, 2013 at 01:08:17PM +0200, LukA!A! Czerner wrote:
> On Tue, 23 Apr 2013, Zheng Liu wrote:
[snip]
> > > > Also update respective tracepoints to use signed long long type for
> > > > partial_cluster.
> > >   The patch looks OK. You can add:
> > > Reviewed-by: Jan Kara <jack@suse.cz>
> > > 
> > >   Just a minor nit - sometimes you use 'signed long long', sometimes 'long
> > > long int', sometimes just 'long long'. In kernel we tend to always use just
> > > 'long long' so it would be good to clean that up.
> > 
> > Another question is that in patch 01/18 invalidatepage signature is
> > changed from
> >   int (*invalidatepage) (struct page *, unsigned long);
> > to
> >   void (*invalidatepage) (struct page *, unsigned int, unsigned int);
> > 
> > The argument type is changed from 'unsigned long' to 'unsigned int'.  My
> > question is why we need to change it.
> > 
> > Thanks,
> >                                                 - Zheng
> > 
> 
> Hi Zheng,
> 
> this was changed on Hugh Dickins request because it makes it clearer
> that those args are indeed intended to be offsets within a page
> (0..PAGE_CACHE_SIZE).
> 
> Even though PAGE_CACHE_SIZE can be defined as unsigned long, this is
> only for convenience. Here is quote from Hugh:
> 
>   "
>   They would be defined as unsigned long so that they can be used in
>   masks like ~(PAGE_SIZE - 1), and behave as expected on addresses,
>   without needing casts to be added all over.
> 
>   We do not (currently!) expect PAGE_SIZE or PAGE_CACHE_SIZE to grow
>   beyond an unsigned int - but indeed they can be larger than what's
>   held in an unsigned short (look no further than ia64 or ppc64).
> 
>   For more reassurance, see include/linux/highmem.h, which declares
>   zero_user_segments() and others: unsigned int (well, unsigned with
>   the int implicit) for offsets within a page.
> 
>   Hugh
>   "
> 
> I should probably mention that in the description.

Ah, thanks for your explanation.  I must miss something. :-(

Regards,
                                                - Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
