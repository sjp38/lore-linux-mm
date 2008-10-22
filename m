Message-ID: <48FF71D3.8060505@cs.columbia.edu>
Date: Wed, 22 Oct 2008 14:32:51 -0400
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint	restart
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu> <1224481237-4892-3-git-send-email-orenl@cs.columbia.edu> <20081021124130.a002e838.akpm@linux-foundation.org> <20081021202410.GA10423@us.ibm.com> <48FE82DF.6030005@cs.columbia.edu> <20081022152804.GA23821@us.ibm.com> <48FF4EB2.5060206@cs.columbia.edu> <20081022170325.GA4908@us.ibm.com>
In-Reply-To: <20081022170325.GA4908@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, tglx@linutronix.de, dave@linux.vnet.ibm.com, mingo@elte.hu, hpa@zytor.com, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>


Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl@cs.columbia.edu):
>>
>> Serge E. Hallyn wrote:
>>> Quoting Oren Laadan (orenl@cs.columbia.edu):
>>> Just thinking aloud...
>>>
>>> Is read mode appropriate?  The user can edit the statefile and restart
>>> it.  Admittedly the restart code should then do all the appropriate
>>> checks for recreating resources, but I'm having a hard time thinking
>>> through this straight.
>>>
>>> Let's say hallyn is running passwd.  ruid=500,euid=0.  He quickly
>>> checkpoints.  Then he restarts.  Will restart say "ok, the /bin/passwd
>>> binary is setuid 0 so let hallyn take euid=0 for this?"  I guess not.
>>> But are there other resources for which this is harder to get right?
>> I'd say that checkpoint and restart are separate.
>>
>> In checkpoint, you read the state and save it somewhere; you don't
>> modify anything in the target task (container). This equivalent to
>> ptrace read-mode. If you could do ptrace, you could save all that
>> state. In fact, you could save it in a format that is suitable for
>> a future restart ... (or just forge one !)
> 
> Yeah, that's convincing.
> 
>> In restart, we either don't trust the user and keep everything to
>> be done with her credentials, of we trust the root user and allow
>> all operations (like loading a kernel module).
>>
>> We can actually have both modes of operations. How to decide that
>> we trust the user is a separate question:  one option is to have
>> both checkpoint and restart executables setuid - checkpoint will
>> sign (in user space) the output image, and restart (in user space)
>> will validate the signature, before passing it to the kenrel. Surely
>> there are other ways...
> 
> Makes sense.
> 
> ...
> 
>>> Hmm, so do you think we just always use the caller's credentials?
>> Nope, since we will fail to restart in many cases. We will need a way
>> to move from caller's credentials to saved credentials, and even from
>> caller's credentials to privileged credentials (e.g. to reopen a file
>> that was created by a setuid program prior to dropping privileges).
> 
> Can we agree to worry about that much much later? :)  Would you agree

Definitely. Even more so - I believe that's a user-space issue :)

> that for the majority of use-cases, restarting with caller's credentials
> will work?  Or am I wrong about that?

That depends on your target audience. For HPC you're probably right.
For server applications this may not be the case (e.g. apache needs
a privileged port, and then it drops privileges).

I agree that we may safely (...) defer this discussion until the
implementation gets much beefier.

> 
>> To do that, we will need to agree on a way to escalate/change the
>> credentials. This however belongs to user-space (and then the binaries
>> for checkpoint/restart will be setuid themselves).
> 
> Ok those are less scary, and I have no problem with those.
> 
>> There will also be the issue of mapping credentials: a user A may have
>> one UID/GID on once system and another UID/GID on another system, and
>> we may want to do the conversion. This, too, can be done in user space
>> prior to restart by using an appropriate filter through the checkpoint
>> stream.
> 
> User namespaces may help here too.  So user A can create a new user
> namespace and restart as user B in that namespace.  But right now that
> sounds like overkill.

Indeed, virtualization is probably the solution. Here, too, I think
it's safe to defer the discussion.

Oren.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
