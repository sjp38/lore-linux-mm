Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 94FAC6B0258
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 12:33:44 -0400 (EDT)
Received: by lbbyj8 with SMTP id yj8so140498714lbb.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 09:33:44 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id a7si1633019lab.49.2015.07.22.09.33.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 09:33:42 -0700 (PDT)
Date: Wed, 22 Jul 2015 19:33:17 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 5/8] mmu-notifier: add clear_young callback
Message-ID: <20150722163317.GO23374@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <e4ab6e8be3f9f94fe9814219c4a9a19c375a5835.1437303956.git.vdavydov@parallels.com>
 <CAJu=L5_q=xWfANDBX2-Z3=uudof+ifKS56zEtAR372VqDWOj2Q@mail.gmail.com>
 <20150721085108.GA18673@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150721085108.GA18673@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg
 Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David
 Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Andrew,

Would you mind merging this incremental patch to the original one? Or
should I better resubmit the whole series with all the fixes?

On Tue, Jul 21, 2015 at 11:51:08AM +0300, Vladimir Davydov wrote:
> On Mon, Jul 20, 2015 at 11:34:21AM -0700, Andres Lagar-Cavilla wrote:
> > On Sun, Jul 19, 2015 at 5:31 AM, Vladimir Davydov <vdavydov@parallels.com>
> [...]
> > > +static int kvm_mmu_notifier_clear_young(struct mmu_notifier *mn,
> > > +                                       struct mm_struct *mm,
> > > +                                       unsigned long start,
> > > +                                       unsigned long end)
> > > +{
> > > +       struct kvm *kvm = mmu_notifier_to_kvm(mn);
> > > +       int young, idx;
> > > +
> > >
> > If you need to cut out another version please add comments as to the two
> > issues raised:
> > - This doesn't proactively flush TLBs -- not obvious if it should.
> > - This adversely affects performance in Pre_haswell Intel EPT.
> 
> Oops, I stopped reading your e-mail in reply to the previous version of
> this patch as soon as I saw the Reviewed-by tag, so I missed your
> request for the comment, sorry about that.
> 
> Here it goes (incremental):
> ---
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index ff4173ce6924..e69a5cb99571 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -397,6 +397,19 @@ static int kvm_mmu_notifier_clear_young(struct mmu_notifier *mn,
>  
>  	idx = srcu_read_lock(&kvm->srcu);
>  	spin_lock(&kvm->mmu_lock);
> +	/*
> +	 * Even though we do not flush TLB, this will still adversely
> +	 * affect performance on pre-Haswell Intel EPT, where there is
> +	 * no EPT Access Bit to clear so that we have to tear down EPT
> +	 * tables instead. If we find this unacceptable, we can always
> +	 * add a parameter to kvm_age_hva so that it effectively doesn't
> +	 * do anything on clear_young.
> +	 *
> +	 * Also note that currently we never issue secondary TLB flushes
> +	 * from clear_young, leaving this job up to the regular system
> +	 * cadence. If we find this inaccurate, we might come up with a
> +	 * more sophisticated heuristic later.
> +	 */
>  	young = kvm_age_hva(kvm, start, end);
>  	spin_unlock(&kvm->mmu_lock);
>  	srcu_read_unlock(&kvm->srcu, idx);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
