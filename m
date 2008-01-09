Message-ID: <47854868.60604@redhat.com>
Date: Wed, 09 Jan 2008 17:19:20 -0500
From: Peter Staubach <staubach@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC][BUG] updating the ctime and mtime time stamps in
 msync()
References: <1199728459.26463.11.camel@codedot>	<20080109155015.4d2d4c1d@cuia.boston.redhat.com>	<26932.1199912777@turing-police.cc.vt.edu> <20080109170633.292644dc@cuia.boston.redhat.com>
In-Reply-To: <20080109170633.292644dc@cuia.boston.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Valdis.Kletnieks@vt.edu, Anton Salikhmetov <salikhmetov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Wed, 09 Jan 2008 16:06:17 -0500
> Valdis.Kletnieks@vt.edu wrote:
>   
>> On Wed, 09 Jan 2008 15:50:15 EST, Rik van Riel said:
>>
>>     
>>> Could you explain (using short words and simple sentences) what the
>>> exact problem is?
>>>       
>> It's like this:
>>
>> Monday  9:04AM:  System boots, database server starts up, mmaps file
>> Monday  9:06AM:  Database server writes to mmap area, updates mtime/ctime
>> Monday <many times> Database server writes to mmap area, no further update..
>> Monday 11:45PM:  Backup sees "file modified 9:06AM, let's back it up"
>> Tuesday 9:00AM-5:00PM: Database server touches it another 5,398 times, no mtime
>> Tuesday 11:45PM: Backup sees "file modified back on Monday, we backed this up..
>> Wed  9:00AM-5:00PM: More updates, more not touching the mtime
>> Wed  11:45PM: *yawn* It hasn't been touched in 2 days, no sense in backing it up..
>>
>> Lather, rinse, repeat....
>>     
>
> On the other hand, updating the mtime and ctime whenever a page is dirtied
> also does not work right.  Apparently that can break mutt.
>
>   

Could you elaborate on why that would break mutt?  I am assuming
that the pages being modified are mmap'd, but if they are not, then
it is very clear why mutt (and anything else) would break.

> Calling msync() every once in a while with Anton's patch does not look like a
> fool proof method to me either, because the VM can write all the dirty pages
> to disk by itself, leaving nothing for msync() to detect.  (I think...)
>
> Can we get by with simply updating the ctime and mtime every time msync()
> is called, regardless of whether or not the mmaped pages were still dirty
> by the time we called msync() ?

As long as we can keep track of that information and then remember
it for an munmap so that eventually the file times do get updated,
then this should work.

It would seem that a better solution would be to update the file
times whenever the inode gets cleaned, ie. modified pages written
out and the inode synchronized to the disk.  That way, long running
programs would not have to msync occasionally in order to have
the data file properly backed up.

    Thanx...

       ps

       ps

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
