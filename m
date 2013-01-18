Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 960C36B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 14:09:43 -0500 (EST)
Message-ID: <50F99E08.4060107@parallels.com>
Date: Fri, 18 Jan 2013 11:10:00 -0800
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/19] list_lru: per-node list infrastructure
References: <1354058086-27937-1-git-send-email-david@fromorbit.com> <1354058086-27937-10-git-send-email-david@fromorbit.com> <50F6FDC8.5020909@parallels.com> <20130116225521.GF2498@dastard> <50F7475F.90609@parallels.com> <20130117042245.GG2498@dastard> <50F84118.7030608@parallels.com> <20130118001029.GK2498@dastard> <50F893D2.7080103@parallels.com> <20130118081133.GQ2498@dastard>
In-Reply-To: <20130118081133.GQ2498@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Suleiman Souhlal <suleiman@google.com>

On 01/18/2013 12:11 AM, Dave Chinner wrote:
> On Thu, Jan 17, 2013 at 04:14:10PM -0800, Glauber Costa wrote:
>> On 01/17/2013 04:10 PM, Dave Chinner wrote:
>>> And then each object uses:
>>>
>>> struct lru_item {
>>> 	struct list_head global_list;
>>> 	struct list_head memcg_list;
>>> }
>> by objects you mean dentries, inodes, and the such, right?
> 
> Yup.
> 
>> Would it be acceptable to you?
> 
> If it works the way I think it should, then yes.
> 
>> We've been of course doing our best to avoid increasing the size of the
>> objects, therefore this is something we've never mentioned. However, if
>> it would be acceptable from the fs POV, this would undoubtedly make our
>> life extremely easier.
> 
> I've been trying hard to work out how to avoid increasing the size
> of structures as well. But if we can't work out how to implement
> something sanely with only a single list head per object to work
> from, then increasing the size of objects is something that we need
> to consider if it solves all the problems we are trying to solve.
> 
> i.e. if adding a second list head makes the code dumb, simple,
> obviously correct and hard to break then IMO it's a no-brainer.
> But we have to tick all the right boxes first...
> 

One of our main efforts recently has been trying to reduce memcg impact
when it is not in use, even if its compiled in. So what really bothers
me here is the fact that we are increasing the size of dentries and
inodes no matter what.

Still within the idea of exploring the playing field, would an
indirection be worth it ?
We would increase the total per-object memory usage by 8 bytes instead
of 16: the dentry gets a pointer, and a separate allocation for the
list_lru. When memcg is not being actively used, we can allocate a
smaller list_lru, with only the global list. When it is, we allocate the
whole thing.

Embedding the lru is certainly easier from my PoV, the main question is
how much do you, as a fs representative, value those 8 bytes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
