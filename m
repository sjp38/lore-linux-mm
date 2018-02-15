Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB4526B0006
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 22:40:55 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d137so3047781pga.6
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 19:40:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q79si533054pfi.105.2018.02.14.19.40.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 19:40:54 -0800 (PST)
Date: Wed, 14 Feb 2018 19:40:50 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 2/8] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-ID: <20180215034050.GA5775@bombadil.infradead.org>
References: <20180214201154.10186-1-willy@infradead.org>
 <20180214201154.10186-3-willy@infradead.org>
 <1518641152.3678.28.camel@perches.com>
 <20180214211203.GF20627@bombadil.infradead.org>
 <20180214155833.9f1563b87391f7ff79ca7ed0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180214155833.9f1563b87391f7ff79ca7ed0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joe Perches <joe@perches.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Feb 14, 2018 at 03:58:33PM -0800, Andrew Morton wrote:
> On Wed, 14 Feb 2018 13:12:03 -0800 Matthew Wilcox <willy@infradead.org> wrote:
> > If C macros had decent introspection, I'd like it to be:
> > 
> > 	sev = kvzalloc_struct(elems, GFP_KERNEL);
> > 
> > and have the macro examine the structure pointed to by 'sev', check
> > the last element was an array, calculate the size of the array element,
> > and call kvzalloc_ab_c.  But we don't live in that world, so I have to
> > get the programmer to tell me the structure and the name of the last
> > element in it.
> 
> hm, bikeshedding fun.

Heck, yeah!  Fun!

> struct foo {
> 	whatevs;
> 	struct bar[0];
> }
> 
> 
> 	struct foo *a_foo;
> 
> 	a_foo = kvzalloc_struct_buf(foo, bar, nr_bars);
> 
> and macro magic will insert the `struct' keyword.  This will help to
> force a miscompile if inappropriate types are used for foo and bar.
> 
> Problem is, foo may be a union(?) and bar may be a scalar type.  So
> 
> 	a_foo = kvzalloc_struct_buf(struct foo, struct bar, nr_bars);
> 
> or, of course.
> 
> 	a_foo = kvzalloc_struct_buf(typeof(*a_foo), typeof(a_foo->bar[0]),
> 				    nr_bars);
> 
> or whatever.

I think that's actually *less* checking than the option I presented here.
My version has the compiler check:
1. You assigned the pointer to the allocated memory
2. ... to a pointer of compatible type with p
3. p is a pointer
4. member is a member of the type p points to
5. member is an array type

Your version doesn't check point 4, and it'd be easy to get it wrong like this:

struct quux {
	int n;
	struct foo foos[];
} *p = kvmalloc_struct(struct quux, struct foo *, n);

or vice-versa:

struct quux {
	int n;
	struct foo *foos[];
} *p = kvmalloc_struct(struct quux, struct foo, n);

What is it that you don't like about my version?  Is it passing the
uninitialised pointer to a macro that looks like a function?  Because
we do this all the time:

	struct foo *p = kmalloc(sizeof(*p), GFP_KERNEL);

> The basic idea is to use the wrapper macros to force compile errors if
> these things are misused.

Right.  Although passing the pointer in lets us work this magic on an
unnamed struct.  Like this mess...

diff --git a/arch/x86/events/intel/uncore.c b/arch/x86/events/intel/uncore.c
index 7874c980d569..5cd3e127bea8 100644
--- a/arch/x86/events/intel/uncore.c
+++ b/arch/x86/events/intel/uncore.c
@@ -792,7 +792,7 @@ static void uncore_type_exit(struct intel_uncore_type *type)
 		kfree(type->pmus);
 		type->pmus = NULL;
 	}
-	kfree(type->events_group);
+	kvfree(type->events_group);
 	type->events_group = NULL;
 }
 
@@ -805,8 +805,6 @@ static void uncore_types_exit(struct intel_uncore_type **types)
 static int __init uncore_type_init(struct intel_uncore_type *type, bool setid)
 {
 	struct intel_uncore_pmu *pmus;
-	struct attribute_group *attr_group;
-	struct attribute **attrs;
 	size_t size;
 	int i, j;
 
@@ -831,21 +829,24 @@ static int __init uncore_type_init(struct intel_uncore_type *type, bool setid)
 				0, type->num_counters, 0, 0);
 
 	if (type->event_descs) {
+		struct {
+			struct attribute_group group;
+			struct attribute *attrs[];
+		} *attr_group;
 		for (i = 0; type->event_descs[i].attr.attr.name; i++);
 
-		attr_group = kzalloc(sizeof(struct attribute *) * (i + 1) +
-					sizeof(*attr_group), GFP_KERNEL);
+		attr_group = kvzalloc_struct(attr_group, attrs, i + 1,
+								GFP_KERNEL);
 		if (!attr_group)
 			goto err;
 
-		attrs = (struct attribute **)(attr_group + 1);
-		attr_group->name = "events";
-		attr_group->attrs = attrs;
+		attr_group->group.name = "events";
+		attr_group->group.attrs = attr_group->attrs;
 
 		for (j = 0; j < i; j++)
-			attrs[j] = &type->event_descs[j].attr.attr;
+			attr_group->attrs[j] = &type->event_descs[j].attr.attr;
 
-		type->events_group = attr_group;
+		type->events_group = &attr_group->group;
 	}
 
 	type->pmu_group = &uncore_pmu_attr_group;

> > +static inline __must_check
> > +void *kvmalloc_ab_c(size_t n, size_t size, size_t c, gfp_t gfp)
> > +{
> > +	if (size != 0 && n > (SIZE_MAX - c) / size)
> > +		return NULL;
> > +
> > +	return kvmalloc(n * size + c, gfp);
> > +}
> 
> Can we please avoid the single-char identifiers?
> 
> void *kvmalloc_ab_c(size_t n_elems, size_t elem_size, size_t header_size,
> 		    gfp_t gfp);
> 
> makes the code so much more readable.

I was naming for consistency:

static inline void *kvmalloc_array(size_t n, size_t size, gfp_t flags)
{
        if (size != 0 && n > SIZE_MAX / size)
                return NULL;

I'll happily change 'c' to 'hdr_size' though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
