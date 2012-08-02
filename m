Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 7D3C46B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 06:32:51 -0400 (EDT)
Date: Thu, 2 Aug 2012 03:32:44 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
Message-ID: <20120802103244.GA23318@leaf>
References: <20120731182330.GD21292@google.com>
 <50197348.9010101@gmail.com>
 <20120801182112.GC15477@google.com>
 <50197460.8010906@gmail.com>
 <20120801182749.GD15477@google.com>
 <50197E4A.7020408@gmail.com>
 <20120801202432.GE15477@google.com>
 <5019B0B4.1090102@gmail.com>
 <20120801224556.GF15477@google.com>
 <501A4FC1.8040907@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <501A4FC1.8040907@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On Thu, Aug 02, 2012 at 12:00:33PM +0200, Sasha Levin wrote:
> On 08/02/2012 12:45 AM, Tejun Heo wrote:
> > On Thu, Aug 02, 2012 at 12:41:56AM +0200, Sasha Levin wrote:
> >> How would your DEFINE_HASHTABLE look like if we got for the simple
> >> 'struct hash_table' approach?
> > 
> > I think defining a different enclosing anonymous struct which the
> > requested number of array entries and then aliasing the actual
> > hash_table to that symbol should work.  It's rather horrible and I'm
> > not sure it's worth the trouble.
> 
> I agree that this is probably not worth the trouble.
> 
> At the moment I see two alternatives:
> 
> 1. Dynamically allocate the hash buckets.
> 
> 2. Use the first bucket to store size. Something like the follows:
> 
> 	#define HASH_TABLE(name, bits)	\
>         	struct hlist_head name[1 << bits + 1];
> 
> 	#define HASH_TABLE_INIT (bits) ({name[0].next = bits});
> 
> And then have hash_{add,get} just skip the first bucket.
> 
> 
> While it's not a pretty hack, I don't see a nice way to avoid having to dynamically allocate buckets for all cases.

What about using a C99 flexible array member?  Kernel style prohibits
variable-length arrays, but I don't think the same rationale applies to
flexible array members.

struct hash_table {
    size_t count;
    struct hlist_head buckets[];
};

#define DEFINE_HASH_TABLE(name, length) struct hash_table name = { .count = length, .buckets = { [0 ... (length - 1)] = HLIST_HEAD_INIT } }

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
