Subject: Re: [Bug 200105] High paging activity as soon as the swap is touched
 (with steps and code to reproduce it)
References: <bug-200105-8545@https.bugzilla.kernel.org/>
 <bug-200105-8545-FomWhXSVhq@https.bugzilla.kernel.org/>
 <191624267.262238.1532074743289@mail.yahoo.com>
 <f20b1529-fcb9-8d0a-6259-fe76977e00d6@gmail.com>
 <20180723130235.GF31229@dhcp22.suse.cz>
From: Daniel Jordan <lkmldmj@gmail.com>
Message-ID: <71c2d8a5-c29e-9284-67ab-bde6d3f0122e@gmail.com>
Date: Tue, 9 Oct 2018 21:35:14 -0400
MIME-Version: 1.0
In-Reply-To: <20180723130235.GF31229@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: john terragon <terragonjohn@yahoo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Jordan <daniel.m.jordan@oracle.com>
List-ID: <linux-mm.kvack.org>



On 7/23/18 9:02 AM, Michal Hocko wrote:
> [I am really sorry to be slow on responding]
> 
> On Sat 21-07-18 10:39:05, Daniel Jordan wrote:
>> John's issue only happens using a LUKS encrypted swap partition,
>> unencrypted swap or swap encrypted without LUKS works fine.
>>
>> In one test (out5.txt) where most system memory is taken by anon pages
>> beforehand, the heavy direct reclaim that Michal noticed lasts for 24
>> seconds, during which on average if I've crunched my numbers right,
>> John's test program was allocating at 4MiB/s, the system overall
>> (pgalloc_normal) was allocating at 235MiB/s, and the system was
>> swapping out (pswpout) at 673MiB/s. pgalloc_normal and pswpout stay
>> roughly the same each second, no big swings.
>>
>> Is the disparity between allocation and swapout rate expected?
>>
>> John ran perf during another test right before the last test program
>> was started (this doesn't include the initial large allocation
>> bringing the system close to swapping).  The top five allocators
>> (kmem:mm_page_alloc):
>>
>> # Overhead      Pid:Command
>> # ........  .......................
>> #
>>      48.45%     2005:memeater     # the test program
>>      32.08%       73:kswapd0
>>       3.16%     1957:perf_4.17
>>       1.41%     1748:watch
>>       1.16%     2043:free
> 
> Huh, kswapd allocating memory sounds really wrong here. Is it possible
> that the swap device driver is double buffering and allocating a new
> page for each one to swap out?
> 
