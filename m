Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 644C36B6D1E
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 07:27:33 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w12-v6so3727669oie.12
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 04:27:33 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y188-v6si13790439oie.238.2018.09.04.04.27.30
        for <linux-mm@kvack.org>;
        Tue, 04 Sep 2018 04:27:30 -0700 (PDT)
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by
 sparse
References: <cover.1535629099.git.andreyknvl@google.com>
 <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <20180831081123.6mo62xnk54pvlxmc@ltop.local>
 <20180831134244.GB19965@ZenIV.linux.org.uk>
 <CAAeHK+w86m6YztnTGhuZPKRczb-+znZ1hiJskPXeQok4SgcaOw@mail.gmail.com>
 <01cadefd-c929-cb45-500d-7043cf3943f6@arm.com>
 <20180903151026.n2jak3e4yqusnogt@ltop.local>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <a31d3400-4523-2bda-a429-f2a221e69ee8@arm.com>
Date: Tue, 4 Sep 2018 12:27:23 +0100
MIME-Version: 1.0
In-Reply-To: <20180903151026.n2jak3e4yqusnogt@ltop.local>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, linux-kselftest@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, Jacob Bramley <Jacob.Bramley@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 03/09/18 16:10, Luc Van Oostenryck wrote:
> On Mon, Sep 03, 2018 at 02:49:38PM +0100, Vincenzo Frascino wrote:
>> On 03/09/18 13:34, Andrey Konovalov wrote:
>>> On Fri, Aug 31, 2018 at 3:42 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>>>> On Fri, Aug 31, 2018 at 10:11:24AM +0200, Luc Van Oostenryck wrote:
>>>>> On Thu, Aug 30, 2018 at 01:41:16PM +0200, Andrey Konovalov wrote:
>>>>>> This patch adds __force annotations for __user pointers casts detected by
>>>>>> sparse with the -Wcast-from-as flag enabled (added in [1]).
>>>>>>
>>>>>> [1] https://github.com/lucvoo/sparse-dev/commit/5f960cb10f56ec2017c128ef9d16060e0145f292
>>>>>
>>>>> Hi,
>>>>>
>>>>> It would be nice to have some explanation for why these added __force
>>>>> are useful.
>>>
>>> I'll add this in the next version, thanks!
>>>
>>>>         It would be even more useful if that series would either deal with
>>>> the noise for real ("that's what we intend here, that's what we intend there,
>>>> here's a primitive for such-and-such kind of cases, here we actually
>>>> ought to pass __user pointer instead of unsigned long", etc.) or left it
>>>> unmasked.
>>>>
>>>>         As it is, __force says only one thing: "I know the code is doing
>>>> the right thing here".  That belongs in primitives, and I do *not* mean the
>>>> #define cast_to_ulong(x) ((__force unsigned long)(x))
>>>> kind.
>>>>
>>>>         Folks, if you don't want to deal with that - leave the warnings be.
>>>> They do carry more information than "someone has slapped __force in that place".
>>>>
>>>> Al, very annoyed by that kind of information-hiding crap...
>>>
>>> This patch only adds __force to hide the reports I've looked at and
>>> decided that the code does the right thing. The cases where this is
>>> not the case are handled by the previous patches in the patchset. I'll
>>> this to the patch description as well. Is that OK?
>>>
>> I think as well that we should make explicit the information that
>> __force is hiding.
>> A possible solution could be defining some new address spaces and use
>> them where it is relevant in the kernel. Something like:
>>
>> # define __compat_ptr __attribute__((noderef, address_space(5)))
>> # define __tagged_ptr __attribute__((noderef, address_space(6)))
>>
>> In this way sparse can still identify the casting and trigger a warning.
>>
>> We could at that point modify sparse to ignore these conversions when a
>> specific flag is passed (i.e. -Wignore-compat-ptr, -Wignore-tagged-ptr)
>> to exclude from the generated warnings the ones we have already dealt
>> with.
>>
>> What do you think about this approach?
> 
> I'll be happy to add such warnings to sparse if it is useful to detect
> (and correct!) problems. I'm also thinking to other possiblities, like
> having some weaker form of __force (maybe simply __force_as (which will
> 'only' force the address space) or even __force_as(TO, FROM) (with TO
> and FROM being a mask of the address space allowed).I believe we need something here to address this type of problems and I like
your proposal of adding a weaker force in the form of __force_as(TO, FROM)
because I think it provides the right level information. 

> However, for the specific situation here, I'm not sure that using
> address spaces is the right choice because I suspect that the concept
> of tagged pointer is orthogonal to the one of (the usual) address space
> (it won't be possible for a pointer to be __tagged_ptr *and* __user).
I was thinking to address spaces because the information seems easily accessible
in sparse [1], but I am certainly open to any solution that can be semantically
more correct.

> 
> OTOH, when I see already the tons of warnings for concepts established
> since many years (I'm thinking especially at __bitwise, see [1]) I'm a
> bit affraid of adding new, more specialized ones that people will
> understand even less how/when they need to use them.
Thanks for providing this statistic, it is very interesting. I understand your
concern, but I think that in this case we need a more specialized option not only
to find potential problems but even to provide the right amount of information
to who reads the code. 

A solution could be to let __force_as(TO, FROM) behave like __force and silence
the warning by default, but have an option in sparse to re-enable it 
(i.e. -Wshow-force-as). 

[1]
---
commit ee7985f0c2b29c96aefe78df4139209eb4e719d8
Author: Vincenzo Frascino <vincenzo.frascino@arm.com>
Date:   Wed Aug 15 10:55:44 2018 +0100

    print address space number for explicit cast to ulong
    
    This patch build on top of commit b34880d ("stricter warning
    for explicit cast to ulong") and prints the address space
    number when a "warning: cast removes address space of expression"
    is triggered.
    
    This makes easier to discriminate in between different address
    spaces.
    
    A validation example is provided as well as part of this patch.
    
    Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>

diff --git a/evaluate.c b/evaluate.c
index 6d5d479..2fc0ebc 100644
--- a/evaluate.c
+++ b/evaluate.c
@@ -3017,8 +3017,12 @@ static struct symbol *evaluate_cast(struct expression *expr)
 		sas = stype->ctype.as;
 	}
 
-	if (!tas && sas > 0)
-		warning(expr->pos, "cast removes address space of expression");
+	if (!tas && sas > 0) {
+		if (Wcast_from_as)
+			warning(expr->pos, "cast removes address space of expression (<asn:%d>)", sas);
+		else
+			warning(expr->pos, "cast removes address space of expression");
+	}
 	if (tas > 0 && sas > 0 && tas != sas)
 		warning(expr->pos, "cast between address spaces (<asn:%d>-><asn:%d>)", sas, tas);
 	if (tas > 0 && !sas &&
diff --git a/sparse.1 b/sparse.1
index 3e13523..699d09f 100644
--- a/sparse.1
+++ b/sparse.1
@@ -84,6 +84,9 @@ This is similar to \fB\-Waddress\-space\fR but will also warn
 on casts to \fBunsigned long\fR.
 
 Sparse does not issues these warnings by default.
+
+When the option is activated the address space number is printed
+as part of the warning message.
 .
 .TP
 .B \-Wcast\-to\-as
diff --git a/validation/Waddress-space-all-attr.c b/validation/Waddress-space-all-attr.c
new file mode 100644
index 0000000..455ba68
--- /dev/null
+++ b/validation/Waddress-space-all-attr.c
@@ -0,0 +1,84 @@
+/* Resembles include/linux/compiler_types.h */
+#define __kernel __attribute__((address_space(0)))
+#define __user __attribute__((address_space(1)))
+#define __iomem __attribute__((address_space(2)))
+#define __percpu __attribute__((address_space(3)))
+#define __rcu __attribute__((address_space(4)))
+
+
+typedef unsigned long ulong;
+typedef long long llong;
+typedef struct s obj_t;
+
+static void expl(obj_t __kernel *k, obj_t __iomem *o,
+		 obj_t __user *p, obj_t __percpu *pc,
+		 obj_t __rcu *r)
+{
+	(int)(k);
+	(ulong)(k);
+	(llong)(k);
+	(void *)(k);
+	(obj_t*)(k);
+	(obj_t __kernel*)(k);
+
+	(int)(o);
+	(ulong)(o);
+	(llong)(o);
+	(void *)(o);
+	(obj_t*)(o);
+	(obj_t __iomem*)(o);
+
+	(int)(p);
+	(ulong)(p);
+	(llong)(p);
+	(void *)(p);
+	(obj_t*)(p);
+	(obj_t __user*)(p);
+
+	(int)(pc);
+	(ulong)(pc);
+	(llong)(pc);
+	(void *)(pc);
+	(obj_t*)(pc);
+	(obj_t __percpu*)(pc);
+
+	(int)(r);
+	(ulong)(r);
+	(llong)(r);
+	(void *)(r);
+	(obj_t*)(r);
+	(obj_t __rcu*)(r);
+}
+
+/*
+ * check-name: Waddress-space-all-attr
+ * check-command: sparse -Wcast-from-as -Wcast-to-as $file
+ *
+ * check-error-start
+Waddress-space-all-attr.c:24:10: warning: cast removes address space of expression (<asn:2>)
+Waddress-space-all-attr.c:25:10: warning: cast removes address space of expression (<asn:2>)
+Waddress-space-all-attr.c:26:10: warning: cast removes address space of expression (<asn:2>)
+Waddress-space-all-attr.c:27:10: warning: cast removes address space of expression (<asn:2>)
+Waddress-space-all-attr.c:28:10: warning: cast removes address space of expression (<asn:2>)
+Waddress-space-all-attr.c:31:10: warning: cast removes address space of expression (<asn:1>)
+Waddress-space-all-attr.c:32:10: warning: cast removes address space of expression (<asn:1>)
+Waddress-space-all-attr.c:33:10: warning: cast removes address space of expression (<asn:1>)
+Waddress-space-all-attr.c:34:10: warning: cast removes address space of expression (<asn:1>)
+Waddress-space-all-attr.c:35:10: warning: cast removes address space of expression (<asn:1>)
+Waddress-space-all-attr.c:38:10: warning: cast removes address space of expression (<asn:3>)
+Waddress-space-all-attr.c:39:10: warning: cast removes address space of expression (<asn:3>)
+Waddress-space-all-attr.c:40:10: warning: cast removes address space of expression (<asn:3>)
+Waddress-space-all-attr.c:41:10: warning: cast removes address space of expression (<asn:3>)
+Waddress-space-all-attr.c:42:10: warning: cast removes address space of expression (<asn:3>)
+Waddress-space-all-attr.c:45:10: warning: cast removes address space of expression (<asn:4>)
+Waddress-space-all-attr.c:46:10: warning: cast removes address space of expression (<asn:4>)
+Waddress-space-all-attr.c:47:10: warning: cast removes address space of expression (<asn:4>)
+Waddress-space-all-attr.c:48:10: warning: cast removes address space of expression (<asn:4>)
+Waddress-space-all-attr.c:49:10: warning: cast removes address space of expression (<asn:4>)
+Waddress-space-all-attr.c:17:10: warning: non size-preserving pointer to integer cast
+Waddress-space-all-attr.c:24:10: warning: non size-preserving pointer to integer cast
+Waddress-space-all-attr.c:31:10: warning: non size-preserving pointer to integer cast
+Waddress-space-all-attr.c:38:10: warning: non size-preserving pointer to integer cast
+Waddress-space-all-attr.c:45:10: warning: non size-preserving pointer to integer cast
+ * check-error-end
+ */


-- 
Regards,
Vincenzo
