Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id BD6F36B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 21:48:57 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so26187284pdj.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 18:48:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id lu16si11247115pab.77.2015.06.09.18.48.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 18:48:56 -0700 (PDT)
Date: Tue, 9 Jun 2015 18:51:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools'
 destroy() functions
Message-Id: <20150609185150.8c9fed8d.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1506092008220.3300@east.gentwo.org>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
	<20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
	<alpine.DEB.2.11.1506092008220.3300@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Joe Perches <joe@perches.com>

On Tue, 9 Jun 2015 20:11:25 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> On Tue, 9 Jun 2015, Andrew Morton wrote:
> 
> > Well I like it, even though it's going to cause a zillion little cleanup
> > patches.
> >
> > checkpatch already has a "kfree(NULL) is safe and this check is
> > probably not required" test so I guess Joe will need to get busy ;)
> >
> > I'll park these patches until after 4.1 is released - it's getting to
> > that time...
> 
> Why do this at all?

For the third time: because there are approx 200 callsites which are
already doing it.

> I understand that kfree/kmem_cache_free can take a
> null pointer but this is the destruction of a cache and it usually
> requires multiple actions to clean things up and these actions have to be
> properly sequenced. All other processors have to stop referencing this
> cache before it can be destroyed. I think failing if someone does
> something strange like doing cache destruction with a NULL pointer is
> valuable.

More than half of the kmem_cache_destroy() callsites are declining that
value by open-coding the NULL test.  That's reality and we should recognize
it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
