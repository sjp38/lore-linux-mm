Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 265226B0044
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 14:08:28 -0400 (EDT)
Received: by weys10 with SMTP id s10so7781714wey.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 11:08:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120802175904.GB6251@jtriplet-mobl1>
References: <20120801202432.GE15477@google.com> <5019B0B4.1090102@gmail.com>
 <20120801224556.GF15477@google.com> <501A4FC1.8040907@gmail.com>
 <20120802103244.GA23318@leaf> <501A633B.3010509@gmail.com>
 <87txwl1dsq.fsf@xmission.com> <501AAC26.6030703@gmail.com>
 <87fw851c3d.fsf@xmission.com> <CA+55aFw_dwO5ZOuaz9eDxgnTZFDGVZKSLUTm5Fn99faALxxJRQ@mail.gmail.com>
 <20120802175904.GB6251@jtriplet-mobl1>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 2 Aug 2012 11:08:06 -0700
Message-ID: <CA+55aFwqC9hF++S-VPHJBFRrqfyNvsvqwzP=Vtzkv8qSYVqLxA@mail.gmail.com>
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On Thu, Aug 2, 2012 at 10:59 AM, Josh Triplett <josh@joshtriplett.org> wrote:
>
> You shouldn't have any extra indirection for the base, if it lives
> immediately after the size.

Umm. You *always* have the extra indirection. Because you have that allocation.

So you have to follow the pointer to get the base/size, because they
aren't compile/link-time constants.

The cache misses were noticeable in macro-benchmarks, and in
micro-benchmarks the smaller L1 hash table means that things fit much
better in the L2.

It really improved performance. Seriously. Even things like "find /"
that had a lot of L1 misses ended up faster, because "find" is
apparently pretty moronic and does some things over and over. For
stuff that fit in the L1, it qas quite noticeable.

Of course, one reason for the speedup for the dcache was that I also
made the L1 only contain the simple cases (ie no "d_compare" thing
etc), so it speeded up dcache lookups in other ways too. But according
to the profiles, it really looked like better cache behavior was one
of the bigger things.

Trust me: every problem in computer science may be solved by an
indirection, but those indirections are *expensive*. Pointer chasing
is just about the most expensive thing you can do on modern CPU's.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
