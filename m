Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id D32BD6B0037
	for <linux-mm@kvack.org>; Wed, 21 May 2014 10:45:58 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id j5so3402331qga.0
        for <linux-mm@kvack.org>; Wed, 21 May 2014 07:45:58 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id z32si1607777qgz.98.2014.05.21.07.45.57
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 07:45:58 -0700 (PDT)
Date: Wed, 21 May 2014 09:45:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
In-Reply-To: <20140521135826.GA23193@esperanza>
Message-ID: <alpine.DEB.2.10.1405210944140.8038@gentwo.org>
References: <cover.1399982635.git.vdavydov@parallels.com> <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405141119320.16512@gentwo.org> <20140515071650.GB32113@esperanza> <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
 <20140516132234.GF32113@esperanza> <alpine.DEB.2.10.1405160957100.32249@gentwo.org> <20140519152437.GB25889@esperanza> <alpine.DEB.2.10.1405191056580.22956@gentwo.org> <537A4D27.1050909@parallels.com> <20140521135826.GA23193@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 21 May 2014, Vladimir Davydov wrote:

> Seems I've found a better way to avoid this race, which does not involve
> messing up free hot paths. The idea is to explicitly zap each per-cpu
> partial list by setting it pointing to an invalid ptr. Since
> put_cpu_partial(), which is called from __slab_free(), uses atomic
> cmpxchg for adding a new partial slab to a per cpu partial list, it is
> enough to add a check if partials are zapped there and bail out if so.
>
> The patch doing the trick is attached. Could you please take a look at
> it once time permit?

Well if you set s->cpu_partial = 0 then the slab should not be added to
the partial lists. Ok its put on there temporarily but then immediately
moved to the node partial list in put_cpu_partial().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
