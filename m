Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id E52A76B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 15:38:08 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Hung task when calling clone() due to netfilter/slab
References: <1326558605.19951.7.camel@lappy>
	<1326561043.5287.24.camel@edumazet-laptop>
	<1326632384.11711.3.camel@lappy>
	<1326648305.5287.78.camel@edumazet-laptop>
	<alpine.DEB.2.00.1201170910130.4800@router.home>
	<1326813630.2259.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1201170927020.4800@router.home>
	<1326814208.2259.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1201170942240.4800@router.home>
	<alpine.DEB.2.00.1201171620590.14697@router.home>
	<m1bopz2ws3.fsf@fess.ebiederm.org> <m14nvr2vbu.fsf@fess.ebiederm.org>
	<alpine.DEB.2.00.1201191959540.14480@router.home>
	<m1y5t3yuil.fsf@fess.ebiederm.org>
	<alpine.DEB.2.00.1201200848040.25882@router.home>
Date: Fri, 20 Jan 2012 12:40:32 -0800
In-Reply-To: <alpine.DEB.2.00.1201200848040.25882@router.home> (Christoph
	Lameter's message of "Fri, 20 Jan 2012 08:49:57 -0600 (CST)")
Message-ID: <m1k44mt8e7.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, kaber@trash.net, pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>

Christoph Lameter <cl@linux.com> writes:

> On Thu, 19 Jan 2012, Eric W. Biederman wrote:
>
>> On the flip side removing from sysfs with locks held must be done
>> carefully, and as a default I would recommend not to hold locks over
>> removing things from sysfs.  As removal blocks waiting for all of the
>> callers into sysfs those sysfs attributes to complete.
>>
>> It looks like you are ok on the removal because none of the sysfs
>> attributes appear to take the slub_lock, just /proc/slabinfo.  But
>> it does look like playing with fire.
>
> Ok then I guess my last patch is needed to make sysfs operations safe.
>
> It may be good to audit the kernel for locks being held while calling
> sysfs functions. Isnt there a lockdep check that ensures that no locks are
> held?

I don't see a no locks are held check but call_usermodehelper in the
blocking case could certainly use one.

For the sysfs remove case lockdep should work.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
