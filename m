Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 42F896B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 02:54:10 -0400 (EDT)
Date: Mon, 12 Mar 2012 23:50:02 -0700 (PDT)
Message-Id: <20120312.235002.344576347742686103.davem@davemloft.net>
Subject: Re: [PATCH 0/5] Persist printk buffer across reboots.
From: David Miller <davem@davemloft.net>
In-Reply-To: <CAHqTa-3DiZhd_yoRTzp2Np0Rp=_zrfL7CbN_twu+ZZeu7f4ENg@mail.gmail.com>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
	<20120312.225302.488696931454771146.davem@davemloft.net>
	<CAHqTa-3DiZhd_yoRTzp2Np0Rp=_zrfL7CbN_twu+ZZeu7f4ENg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: apenwarr@gmail.com
Cc: akpm@linux-foundation.org, josh@joshtriplett.org, paulmck@linux.vnet.ibm.com, mingo@elte.hu, a.p.zijlstra@chello.nl, fdinitto@redhat.com, hannes@cmpxchg.org, olaf@aepfle.de, paul.gortmaker@windriver.com, tj@kernel.org, hpa@linux.intel.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Avery Pennarun <apenwarr@gmail.com>
Date: Tue, 13 Mar 2012 02:00:30 -0400

> Sounds good to me.  Do you have any pointers?  Just use an
> early_param?  If we see the early_param but we can't reserve the
> requested address, should we fall back to probing or disable the
> PRINTK_PERSIST mode entirely?

The interface is prom_retain() in f.e. arch/sparc/prom/misc_64.c

You give it a string name, a size in bytes, and an alignment.  And you
are given a physical address on success.  I'm pretty sure the string
name you give is one of the keys it uses to look up the same piece of
memory for you next time.  So you can have retained memory across soft
resets not just for log buffers, but for other things too.

The idea is that you call prom_retain() before you take a look at what
physical memory is available in the kernel, and the firmware takes
this physical chunk out of those available memory lists upon
prom_retain() success.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
