Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 7D2916B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 15:09:57 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so9020329ied.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 12:09:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121029185319.GA21546@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
 <1351450948-15618-6-git-send-email-levinsasha928@gmail.com>
 <20121029113515.GB9115@Krystal> <CA+1xoqce6uJ6wy3+2CBwsLHKnsz4wD0vt8MBEGKCFfXTvuC0Hg@mail.gmail.com>
 <20121029183157.GC3097@jtriplet-mobl1> <CA+1xoqfMrn9zDFMJNFfA0NA86wE_DedD97cP1yJ2UQdTjs3uyQ@mail.gmail.com>
 <20121029185319.GA21546@Krystal>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 29 Oct 2012 15:09:36 -0400
Message-ID: <CA+1xoqcSx04JEXy2aPu4Qt7Zb4iSqXBSjARgMae_FusgzpgnaQ@mail.gmail.com>
Subject: Re: [PATCH v7 06/16] tracepoint: use new hashtable implementation
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Josh Triplett <josh@joshtriplett.org>, torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Mon, Oct 29, 2012 at 2:53 PM, Mathieu Desnoyers
<mathieu.desnoyers@efficios.com> wrote:
> * Sasha Levin (levinsasha928@gmail.com) wrote:
>> On Mon, Oct 29, 2012 at 2:31 PM, Josh Triplett <josh@joshtriplett.org> wrote:
>> > On Mon, Oct 29, 2012 at 01:29:24PM -0400, Sasha Levin wrote:
>> >> On Mon, Oct 29, 2012 at 7:35 AM, Mathieu Desnoyers
>> >> <mathieu.desnoyers@efficios.com> wrote:
>> >> > * Sasha Levin (levinsasha928@gmail.com) wrote:
>> >> >> Switch tracepoints to use the new hashtable implementation. This reduces the amount of
>> >> >> generic unrelated code in the tracepoints.
>> >> >>
>> >> >> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
>> >> >> ---
>> >> >>  kernel/tracepoint.c | 27 +++++++++++----------------
>> >> >>  1 file changed, 11 insertions(+), 16 deletions(-)
>> >> >>
>> >> >> diff --git a/kernel/tracepoint.c b/kernel/tracepoint.c
>> >> >> index d96ba22..854df92 100644
>> >> >> --- a/kernel/tracepoint.c
>> >> >> +++ b/kernel/tracepoint.c
>> >> >> @@ -26,6 +26,7 @@
>> >> >>  #include <linux/slab.h>
>> >> >>  #include <linux/sched.h>
>> >> >>  #include <linux/static_key.h>
>> >> >> +#include <linux/hashtable.h>
>> >> >>
>> >> >>  extern struct tracepoint * const __start___tracepoints_ptrs[];
>> >> >>  extern struct tracepoint * const __stop___tracepoints_ptrs[];
>> >> >> @@ -49,8 +50,7 @@ static LIST_HEAD(tracepoint_module_list);
>> >> >>   * Protected by tracepoints_mutex.
>> >> >>   */
>> >> >>  #define TRACEPOINT_HASH_BITS 6
>> >> >> -#define TRACEPOINT_TABLE_SIZE (1 << TRACEPOINT_HASH_BITS)
>> >> >> -static struct hlist_head tracepoint_table[TRACEPOINT_TABLE_SIZE];
>> >> >> +static DEFINE_HASHTABLE(tracepoint_table, TRACEPOINT_HASH_BITS);
>> >> >>
>> >> > [...]
>> >> >>
>> >> >> @@ -722,6 +715,8 @@ struct notifier_block tracepoint_module_nb = {
>> >> >>
>> >> >>  static int init_tracepoints(void)
>> >> >>  {
>> >> >> +     hash_init(tracepoint_table);
>> >> >> +
>> >> >>       return register_module_notifier(&tracepoint_module_nb);
>> >> >>  }
>> >> >>  __initcall(init_tracepoints);
>> >> >
>> >> > So we have a hash table defined in .bss (therefore entirely initialized
>> >> > to NULL), and you add a call to "hash_init", which iterates on the whole
>> >> > array and initialize it to NULL (again) ?
>> >> >
>> >> > This extra initialization is redundant. I think it should be removed
>> >> > from here, and hashtable.h should document that hash_init() don't need
>> >> > to be called on zeroed memory (which includes static/global variables,
>> >> > kzalloc'd memory, etc).
>> >>
>> >> This was discussed in the previous series, the conclusion was to call
>> >> hash_init() either way to keep the encapsulation and consistency.
>> >>
>> >> It's cheap enough and happens only once, so why not?
>> >
>> > Unnecessary work adds up.  Better not to do it unnecessarily, even if by
>> > itself it doesn't cost that much.
>> >
>> > It doesn't seem that difficult for future fields to have 0 as their
>> > initialized state.
>>
>> Let's put it this way: hlist requires the user to initialize hlist
>> head before usage, therefore as a hlist user, hashtable implementation
>> must do that.
>>
>> We do it automatically when the hashtable user does
>> DEFINE_HASHTABLE(), but we can't do that if he does
>> DECLARE_HASHTABLE(). This means that the hashtable user must call
>> hash_init() whenever he uses DECLARE_HASHTABLE() to create his
>> hashtable.
>>
>> There are two options here, either we specify that hash_init() should
>> only be called if DECLARE_HASHTABLE() was called, which is confusing,
>> inconsistent and prone to errors, or we can just say that it should be
>> called whenever a hashtable is used.
>>
>> The only way to work around it IMO is to get hlist to not require
>> initializing before usage, and there are good reasons that that won't
>> happen.
>
> Hrm, just a second here.
>
> The argument about hash_init being useful to add magic values in the
> future only works for the cases where a hash table is declared with
> DECLARE_HASHTABLE(). It's completely pointless with DEFINE_HASHTABLE(),
> because we could initialize any debugging variables from within
> DEFINE_HASHTABLE().
>
> So I take my "Agreed" back. I disagree with initializing the hash table
> twice redundantly. There should be at least "DEFINE_HASHTABLE()" or a
> hash_init() (for DECLARE_HASHTABLE()), but not useless execution
> initialization on top of an already statically initialized hash table.

The "magic values" argument was used to point out that some sort of
initialization *must* occur, either by hash_init() or by a proper
initialization in DEFINE_HASHTABLE(), and we can't simply memset() it
to 0. It appears that we all agree on that.

The other thing is whether hash_init() should be called for hashtables
that were created with DEFINE_HASHTABLE(). That point was raised by
Neil Brown last time this series went around, and it seems that no one
objected to the point that it should be consistent across the code.

Even if we ignore hash_init() being mostly optimized out, is it really
worth it taking the risk that some future patch would move a hashtable
that user DEFINE_HASHTABLE() into a struct and will start using
DECLARE_HASHTABLE() and forgetting to initialize it, for example?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
