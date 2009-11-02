Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EF3466B007B
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 10:31:47 -0500 (EST)
Received: by gv-out-0910.google.com with SMTP id l14so560410gvf.19
        for <linux-mm@kvack.org>; Mon, 02 Nov 2009 07:31:45 -0800 (PST)
Message-ID: <4AEEFB5D.9080009@gmail.com>
Date: Mon, 02 Nov 2009 16:31:41 +0100
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] MM: slqb, fix per_cpu access
References: <1257113578-1584-1-git-send-email-jirislaby@gmail.com> <200911022353.30524.rusty@rustcorp.com.au>
In-Reply-To: <200911022353.30524.rusty@rustcorp.com.au>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: npiggin@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 11/02/2009 02:23 PM, Rusty Russell wrote:
>> --- a/mm/slqb.c
>> +++ b/mm/slqb.c
>> @@ -2770,16 +2770,16 @@ static DEFINE_PER_CPU(struct delayed_work, cache_trim_work);
>>  
>>  static void __cpuinit start_cpu_timer(int cpu)
>>  {
>> -	struct delayed_work *cache_trim_work = &per_cpu(cache_trim_work, cpu);
>> +	struct delayed_work *_cache_trim_work = &per_cpu(cache_trim_work, cpu);
>>  
>>  	/*
>>  	 * When this gets called from do_initcalls via cpucache_init(),
>>  	 * init_workqueues() has already run, so keventd will be setup
>>  	 * at that time.
>>  	 */
>> -	if (keventd_up() && cache_trim_work->work.func == NULL) {
>> -		INIT_DELAYED_WORK(cache_trim_work, cache_trim_worker);
>> -		schedule_delayed_work_on(cpu, cache_trim_work,
>> +	if (keventd_up() && _cache_trim_work->work.func == NULL) {
>> +		INIT_DELAYED_WORK(_cache_trim_work, cache_trim_worker);
>> +		schedule_delayed_work_on(cpu, _cache_trim_work,
>>  					__round_jiffies_relative(HZ, cpu));
> 
> How about calling the local var "trim"?
> 
> This actually makes the code more readable, IMHO.

Please ignore this version of the patch. After this I sent a new one
which changes the global var name.

So the local variable is untouched there. If you want me to perform the
cleanup, let me know. In any case I'd make it trim_work instead of trim
which makes more sense to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
