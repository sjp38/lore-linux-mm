Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4946B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 15:25:34 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id r5so6496995qcx.7
        for <linux-mm@kvack.org>; Thu, 22 May 2014 12:25:33 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id 107si922329qgn.94.2014.05.22.12.25.33
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 12:25:33 -0700 (PDT)
Date: Thu, 22 May 2014 14:25:30 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
In-Reply-To: <20140522134726.GA3147@esperanza>
Message-ID: <alpine.DEB.2.10.1405221422390.15766@gentwo.org>
References: <20140515071650.GB32113@esperanza> <alpine.DEB.2.10.1405151015330.24665@gentwo.org> <20140516132234.GF32113@esperanza> <alpine.DEB.2.10.1405160957100.32249@gentwo.org> <20140519152437.GB25889@esperanza> <alpine.DEB.2.10.1405191056580.22956@gentwo.org>
 <537A4D27.1050909@parallels.com> <alpine.DEB.2.10.1405210937440.8038@gentwo.org> <20140521150408.GB23193@esperanza> <alpine.DEB.2.10.1405211912400.4433@gentwo.org> <20140522134726.GA3147@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 22 May 2014, Vladimir Davydov wrote:

> On Wed, May 21, 2014 at 07:13:21PM -0500, Christoph Lameter wrote:
> > On Wed, 21 May 2014, Vladimir Davydov wrote:
> >
> > > Do I understand you correctly that the following change looks OK to you?
> >
> > Almost. Preemption needs to be enabled before functions that invoke the
> > page allocator etc etc.
>
> I need to disable preemption only in slab_free, which never blocks
> according to its semantics, so everything should be fine just like that.

slab_free calls __slab_free which can release slabs via
put_cpu_partial()/unfreeze_partials()/discard_slab() to the page
allocator. I'd rather have preemption enabled there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
