Date: Wed, 7 Mar 2007 13:33:25 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 8/6] mm: fix cpdfio vs fault race
In-Reply-To: <20070307130214.56d4b03b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0703071310180.5963@woody.linux-foundation.org>
References: <20070307110429.GF5555@wotan.suse.de>
 <20070307032038.f08333a8.akpm@linux-foundation.org> <20070307113121.GA18704@wotan.suse.de>
 <20070307130214.56d4b03b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, miklos@szeredi.hu, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Wed, 7 Mar 2007, Andrew Morton wrote:
> 
> now that's scary - applying this on top of your
> lock-the-page-in-the-fault-handler patches gives:

This is why you should never use plain "patch" with defaultl arguments in 
a script (and probably not even from an interactive command line).

I've said this before, and I'll say it again: "'patch' is incredibly 
unsafe by default".

Please use

	patch -p1 --fuzz=0

rather than the defaults (adding "-E -u -f" is also often a good idea, 
depending on the source of the patches). And that's *especially* true in 
scripts.

Yeah, "--fuzz=0" means that patch will reject more patches, but the 
patches it rejects tends to be patches it *should* reject, and you should 
take a look at manually (and then you can decide to not use --fuzz=0 if 
you think patch does the right thing by mistake).

Also, *never* use "-l" or some of the other flags that make patch even 
less reliable. It's already guessing enough. Again, "-l" can be useful if 
you're going to check the result manually and fix up whatever bad stuff it 
does, but if it's needed, I can almost guarantee that it *will* need 
fixing up, which is why using those things in automated scripts is not a 
good idea.

If you have git installed, "git apply" has saner defaults than "patch" 
does (with "git apply" you have to explicitly loosen any rules, and it 
doesn't guess by default). "git apply" also checks the whole patch 
"atomically" when applying, so that if there are rejects it won't apply 
things partially and force you to clean up.

The "git apply" behaviour is particularly useful, because since it by 
default doesn't change anything at all on failure, you can start off with 
the strict defaults, and then *if* something goes wrong you can try it 
with less strict settings without having to undo some partial patch mess.

Of course, you can do the same with GNU patch by starting off with a 
dry-run application and seeing that was ok:

	# is it clean
	if patch --dry-run --fuzz=0 -p1 < ...
	then
		# all ok, just patch, no need to ask the user
		patch -p1 < ....
	else
		# this may do bad things, but let's try, and 
		# then tell the user to check the end result
		patch < 
		
		.. generate diff, ask user to check it for sanity ! ..
		.. But *require* manual checking! ..
	fi

My original patch applicator script had

	patch -E -u --no-backup-if-mismatch -f -p1 --fuzz=0

(where that "--no-backup-if-mismatch" is just because with an SCM backing 
the setup up, there's just no point - but it depends on your setup, of 
course). That was because I had (over painful errors) realized that 
allowing fuzz is just a guaranteed way to silently get merge errors.

You can get merge errors even with a zero fuzz (if it happens to find 
another place to apply the patch - especially true in very structured 
files that have lots of identical line snipptes), but it's a lot less 
likely.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
