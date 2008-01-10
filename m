Message-ID: <47864BF2.6020203@redhat.com>
Date: Thu, 10 Jan 2008 11:46:42 -0500
From: Peter Staubach <staubach@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC][BUG] updating the ctime and mtime time stamps in
 msync()
References: <1199728459.26463.11.camel@codedot>	<20080109155015.4d2d4c1d@cuia.boston.redhat.com>	<26932.1199912777@turing-police.cc.vt.edu>	<20080109170633.292644dc@cuia.boston.redhat.com>	<20080109223340.GH25527@unthought.net>	<20080109184141.287189b8@bree.surriel.com>	<4df4ef0c0801091603y2bf507e1q2b99971c6028d1f3@mail.gmail.com>	<20080110085120.GK25527@unthought.net>	<4df4ef0c0801100253m6c08e4a3t917959c030533f80@mail.gmail.com>	<20080110104543.398baf5c@bree.surriel.com>	<4df4ef0c0801100756v2a536cc5xa80d9d1cfdae073a@mail.gmail.com> <20080110110757.09ec494a@bree.surriel.com>
In-Reply-To: <20080110110757.09ec494a@bree.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Anton Salikhmetov <salikhmetov@gmail.com>, Jakob Oestergaard <jakob@unthought.net>, Valdis.Kletnieks@vt.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Thu, 10 Jan 2008 18:56:07 +0300
> "Anton Salikhmetov" <salikhmetov@gmail.com> wrote:
>
>   
>> However, I don't see how they will work if there has been
>> something like a sync(2) done after the mmap'd region is
>> modified and the msync call.  When the inode is written out
>> as part of the sync process, I_DIRTY_PAGES will be cleared,
>> thus causing a miss in this code.
>>
>> The I_DIRTY_PAGES check here is good, but I think that there
>> needs to be some code elsewhere too, to catch the case where
>> I_DIRTY_PAGES is being cleared, but the time fields still need
>> to be updated.
>>     
>
> Agreed. The mtime and ctime should probably also be updated
> when I_DIRTY_PAGES is cleared.
>
> The alternative would be to remember that the inode had been
> dirty in the past, and have the mtime and ctime updated on
> msync or close - which would be more complex.

And also remembering that the file times should not be updated
if the pages were modified via a write(2) operation.  Or if
there has been an intervening write(2) operation...

The number of cases to consider and the boundary conditions
quickly make this reasonably complex to get right.  That's why
this is the 4'th or 5'th attempt in the last 18 months or so
to get this situation addressed.

       ps

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
