Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 8EB3D6B004D
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 15:48:53 -0400 (EDT)
Received: from g5t0029.atlanta.hp.com (g5t0029.atlanta.hp.com [16.228.8.141])
	by g5t0008.atlanta.hp.com (Postfix) with ESMTP id A4A5D24314
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 19:48:52 +0000 (UTC)
Received: from hornet.americas.hpqcorp.net (hornet.americas.hpqcorp.net [16.89.246.191])
	by g5t0029.atlanta.hp.com (Postfix) with ESMTP id 83A402031C
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 19:48:52 +0000 (UTC)
Message-ID: <4F85E024.3070407@hp.com>
Date: Wed, 11 Apr 2012 12:48:52 -0700
From: Don Morris <don.morris@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH] remove BUG() in possible but rare condition
References: <1334167824-19142-1-git-send-email-glommer@parallels.com> <20120411184845.GA24831@tiehlicka.suse.cz> <CA+55aFx1GMWGgh0sTAzvvVSzPQsQ_4NKeaNv1zpKrP4fg1dG+Q@mail.gmail.com> <20120411192052.GB24831@tiehlicka.suse.cz>
In-Reply-To: <20120411192052.GB24831@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On 04/11/2012 12:20 PM, Michal Hocko wrote:
> On Wed 11-04-12 11:57:56, Linus Torvalds wrote:
>> On Wed, Apr 11, 2012 at 11:48 AM, Michal Hocko <mhocko@suse.cz> wrote:
>>>
>>> I am not familiar with the code much but a trivial call chain walk up to
>>> write_dev_supers (in btrfs) shows that we do not check for the return value
>>> from __getblk so we would nullptr and there might be more.
>>> I guess these need some treat before the BUG might be removed, right?
>>
>> Well, realistically, isn't BUG() as bad as a NULL pointer dereference?
>>
>> Do you care about the exact message on the screen when your machine dies?
> 
> I personally do not care as I do not allow anything to map at that area.
> 
> It just seems that there are some callers who do not expect that the
> allocation fails. BUG at the allocation failure which dates back when it
> replaced buffer_error might have let to some assumptions (not good of
> course but we should better fix them.
> 
> That being said I am not against the patch. BUG on an allocation failure
> just doesn't feel right...

Apologies in advance for the relatively wide distribution for what may
be an obvious/stupid question, but if this is in a Documentation/vm
file, I don't see it.

Unless I'm really missing something, the allocation in question uses
GFP_NOFS flags, resulting in a "Wait Ok" request to the underlying
allocators. Other than gotchas like force failures returning a fail
even for Wait-safe allocations... is it actually expected for Wait-safe
kernel allocations to fail? Certainly page requests for user memory
can run afoul of OOM or other mechanisms, and certainly any request
for special/hard memory could be failed... but wouldn't a general small
kernel allocation should generally sleep until satisfied?

That's what the current code looks like to me -- but I could easily
be missing something in the reading, so I'm mainly asking if there's
a general policy to the API here. If it is that non-special kernel
allocations wait until they're satisfied... I'm wondering, why the
test/force mode that seems guaranteed to light off BUG() statements
such as this which are simply validating the allocation contract?

Don Morris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
