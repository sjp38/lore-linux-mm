Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 082C06B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 22:46:44 -0400 (EDT)
Message-ID: <1374029203.6458.121.camel@gandalf.local.home>
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 16 Jul 2013 22:46:43 -0400
In-Reply-To: <0000013fa047b23e-84298a70-911d-43ea-9db3-bc9682bb90b6-000000@email.amazonses.com>
References: <20130614195500.373711648@linux.com>
	 <0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
	 <51BFFFA1.8030402@kernel.org>
	 <0000013f57a5b278-d9104e1e-ccec-40ec-bd95-f8b0816a38d9-000000@email.amazonses.com>
	 <20130618102109.310f4ce1@riff.lan>
	 <CAOJsxLHsYVThWL7yKEQaQqxTSpgK8RHm-u8n94t_m4=uMjDqzw@mail.gmail.com>
	 <1372170272.18733.201.camel@gandalf.local.home>
	 <0000013f9b735739-eb4b29ce-fbc6-4493-ac56-22766da5fdae-000000@email.amazonses.com>
	 <20130702100913.0ef4cd25@riff.lan>
	 <0000013fa047b23e-84298a70-911d-43ea-9db3-bc9682bb90b6-000000@email.amazonses.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Clark Williams <williams@redhat.com>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Joonsoo Kim <js1304@gmail.com>, Clark Williams <clark@redhat.com>, Glauber Costa <glommer@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>

On Tue, 2013-07-02 at 16:47 +0000, Christoph Lameter wrote:
> On Tue, 2 Jul 2013, Clark Williams wrote:
> 
> > What's your recommended method for switching cpu_partial processing
> > off?
> >
> > I'm not all that keen on repeatedly traversing /sys/kernel/slab looking
> > for 'cpu_partial' entries, mainly because if you do it at boot time
> > (i.e. from a startup script) you miss some of the entries.
> 
> Merge the patch that makes a config option and compile it out of the
> kernel?

When I run a stress test of the box (kernel compile along with
hackbench), with that patch applied, the system hangs for long periods
of time. I have no idea why, but the oom killer would trigger
constantly.

Anyway, I'm thinking of just applying this patch. I think it would work
for -rt.

-- Steve

diff --git a/mm/slub.c b/mm/slub.c
index 75a8ffd..a288e72 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -124,6 +124,18 @@ static inline int kmem_cache_debug(struct kmem_cache *s)
 #endif
 }
 
+#ifdef CONFIG_PREEMPT_RT_FULL
+static inline int kmem_cache_debug_rt(struct kmem_cache *s)
+{
+	return 1;
+}
+#else
+static inline int kmem_cache_debug_rt(struct kmem_cache *s)
+{
+	return kmem_cache_debug(s);
+}
+#endif
+
 /*
  * Issues still to be resolved:
  *
@@ -3147,7 +3159,7 @@ static int kmem_cache_open(struct kmem_cache *s,
 	 *    per node list when we run out of per cpu objects. We only fetch 50%
 	 *    to keep some capacity around for frees.
 	 */
-	if (kmem_cache_debug(s))
+	if (kmem_cache_debug_rt(s))
 		s->cpu_partial = 0;
 	else if (s->size >= PAGE_SIZE)
 		s->cpu_partial = 2;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
