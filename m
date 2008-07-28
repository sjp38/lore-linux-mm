From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <11498528.1217234602331.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 28 Jul 2008 17:43:22 +0900 (JST)
Subject: Re: Re: [PATCH 2/2][-mm][resend] memcg limit change shrink usage.
In-Reply-To: <20080722014517.04e88306.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20080722014517.04e88306.akpm@linux-foundation.org>
 <20080714171154.e1cc9943.kamezawa.hiroyu@jp.fujitsu.com>
	<20080714171522.d1cd50e9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

----- Original Message -----

>On Mon, 14 Jul 2008 17:15:22 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fuji
tsu.com> wrote:
>
>> Shrinking memory usage at limit change.
>
>The above six words are all we really have as a changelog.  It is not
>adequate.
>
I'll add enough description (in this week), sorry,


>> +	while (res_counter_set_limit(&memcg->res, val)) {
>> +		if (signal_pending(current)) {
>> +			ret = -EINTR;
>> +			break;
>> +		}
>> +		if (!retry_count) {
>> +			ret = -EBUSY;
>> +			break;
>> +		}
>> +		progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL);
>> +		if (!progress)
>> +			retry_count--;
>> +	}
>> +	return ret;
>> +}
>
>We could perhaps get away with a basically-unchanglogged patch if the
>code was adequately commented.  But it is not.
>
>What the heck does this function *do*?  Why does it exist?
>
Sorry. I should do so.

>Guys, this is core Linux kernel, not some weekend hack project.  Please
>work to make it as comprehensible and as maintainable as we possibly
>can.
>
>Also, it is frequently a mistake for a callee to assume that the caller
>can use GFP_KERNEL.  Often when we do this we end having to change the
>interface so that the caller passes in the gfp_t.  As there's only one
>caller I guess we can get away with it this time.  For now.
>

Hmm, ok. will rework this and take gfp_t as an argument.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
