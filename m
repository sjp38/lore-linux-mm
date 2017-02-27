Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 101906B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:14:10 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w67so7960638wmd.3
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:14:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w5si22087512wra.125.2017.02.27.09.14.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 09:14:09 -0800 (PST)
Date: Mon, 27 Feb 2017 18:14:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/3] percpu: improve allocation success rate for
 non-GFP_KERNEL callers
Message-ID: <20170227171404.GP26504@dhcp22.suse.cz>
References: <201702260805.zhem8KFI%fengguang.wu@intel.com>
 <20170226043829.14270-1-tahsin@google.com>
 <20170227095258.GG14029@dhcp22.suse.cz>
 <CAAeU0aMaGa63Nj=JvZKKy82FftAT9dF56=gZsufDvrkqDSGUrw@mail.gmail.com>
 <20170227152516.GJ26504@dhcp22.suse.cz>
 <CAAeU0aOCGrwmYGPWgA_7Y=2O2RXG_Ux14h4FrogpKPAKvVNaXg@mail.gmail.com>
 <20170227170753.GO26504@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227170753.GO26504@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tahsin Erdogan <tahsin@google.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 27-02-17 18:07:53, Michal Hocko wrote:
> On Mon 27-02-17 09:01:09, Tahsin Erdogan wrote:
> > On Mon, Feb 27, 2017 at 7:25 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > >         /*
> > >          * No space left.  Create a new chunk.  We don't want multiple
> > >          * tasks to create chunks simultaneously.  Serialize and create iff
> > >          * there's still no empty chunk after grabbing the mutex.
> > >          */
> > >         if (is_atomic)
> > >                 goto fail;
> > >
> > > right before pcpu_populate_chunk so is this actually a problem?
> > 
> > Yes, this prevents adding more pcpu chunks and so cause "atomic" allocations
> > to fail more easily.
> 
> Then I fail to see what is the problem you are trying to fix.

To be more specific. Could you describe what more can we do in the
vmalloc layer for GFP_NOWAIT allocations? They certainly cannot sleep
and cannot perform the reclaim so you have to rely on the background
work.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
