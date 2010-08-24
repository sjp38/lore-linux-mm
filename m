Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8CD2F6B0353
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 05:36:34 -0400 (EDT)
Message-ID: <4C73928A.4040601@redhat.com>
Date: Tue, 24 Aug 2010 12:36:10 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 12/12] Send async PF when guest is not in userspace
 too.
References: <1279553462-7036-1-git-send-email-gleb@redhat.com> <1279553462-7036-13-git-send-email-gleb@redhat.com>
In-Reply-To: <1279553462-7036-13-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 07/19/2010 06:31 PM, Gleb Natapov wrote:
> If guest indicates that it can handle async pf in kernel mode too send
> it, but only if interrupt are enabled.
>
> Reviewed-by: Rik van Riel<riel@redhat.com>
> Signed-off-by: Gleb Natapov<gleb@redhat.com>
> ---
>   arch/x86/kvm/mmu.c |    8 +++++++-
>   1 files changed, 7 insertions(+), 1 deletions(-)
>
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index 12d1a7b..ed87b1c 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -2361,7 +2361,13 @@ static bool can_do_async_pf(struct kvm_vcpu *vcpu)
>   	if (!vcpu->arch.apf_data || kvm_event_needs_reinjection(vcpu))
>   		return false;
>
> -	return !!kvm_x86_ops->get_cpl(vcpu);
> +	if (vcpu->arch.apf_send_user_only)
> +		return !!kvm_x86_ops->get_cpl(vcpu);

cpl is not a bool.  Compare it with 0.

> +
> +	if (!kvm_x86_ops->interrupt_allowed(vcpu))
> +		return false;
> +
> +	return true;
>   }

Should have commented before, but get_cpl() is not accurate when doing 
nested virtualization.  When L1 intercepts page faults, being in L2 is 
equivalent to CPL 3.  But we need to get the apf information to L1 somehow.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
