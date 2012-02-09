Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 5ABA96B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 19:03:46 -0500 (EST)
Date: Wed, 8 Feb 2012 16:03:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 4/8] smp: add func to IPI cpus based on parameter
 func
Message-Id: <20120208160344.88d187e5.akpm@linux-foundation.org>
In-Reply-To: <op.v9csppvv3l0zgt@mpn-glaptop>
References: <1328448800-15794-1-git-send-email-gilad@benyossef.com>
	<1328449722-15959-3-git-send-email-gilad@benyossef.com>
	<op.v9csppvv3l0zgt@mpn-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: linux-kernel@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Chris Metcalf <cmetcalf@tilera.com>, Christoph Lameter <cl@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Wed, 08 Feb 2012 10:30:51 +0100
"Michal Nazarewicz" <mina86@mina86.com> wrote:

> >  	} while (0)
> > +/*
> > + * Preemption is disabled here to make sure the
> > + * cond_func is called under the same condtions in UP
> > + * and SMP.
> > + */
> > +#define on_each_cpu_cond(cond_func, func, info, wait, gfp_flags) \
> > +	do {						\
> 
> How about:
> 
> 		void *__info = (info);
> 
> as to avoid double execution.

Yup.  How does this look?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: smp-add-func-to-ipi-cpus-based-on-parameter-func-update-fix

- avoid double-evaluation of `info' (per Michal)
- parenthesise evaluation of `cond_func'

Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/smp.h |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- a/include/linux/smp.h~smp-add-func-to-ipi-cpus-based-on-parameter-func-update-fix
+++ a/include/linux/smp.h
@@ -168,10 +168,11 @@ static inline int up_smp_call_function(s
  */
 #define on_each_cpu_cond(cond_func, func, info, wait, gfp_flags)\
 	do {							\
+		void *__info = (info);				\
 		preempt_disable();				\
-		if (cond_func(0, info)) {			\
+		if ((cond_func)(0, __info)) {			\
 			local_irq_disable();			\
-			(func)(info);				\
+			(func)(__info);				\
 			local_irq_enable();			\
 		}						\
 		preempt_enable();				\
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
