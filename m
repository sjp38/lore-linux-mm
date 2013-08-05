Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 358686B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 21:14:05 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id g12so5042696oah.34
        for <linux-mm@kvack.org>; Sun, 04 Aug 2013 18:14:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130804080751.GA24005@dhcp22.suse.cz>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
 <20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
 <51F9D1F6.4080001@jp.fujitsu.com> <20130731201708.efa5ae87.akpm@linux-foundation.org>
 <CAHGf_=r7mek+ueJWfu_6giMOueDTnMs8dY1jJrKyX+gfPys6uA@mail.gmail.com>
 <20130802073304.GA17746@dhcp22.suse.cz> <51FD653A.3060004@jp.fujitsu.com> <20130804080751.GA24005@dhcp22.suse.cz>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sun, 4 Aug 2013 21:13:44 -0400
Message-ID: <CAHGf_=o19rxB=neUPzZAeL9eeLnksKcbqCJjc+vg=EhYtnuwCw@mail.gmail.com>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info message
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dave.hansen@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, bp@suse.de, Dave Hansen <dave@linux.vnet.ibm.com>

On Sun, Aug 4, 2013 at 4:07 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Sat 03-08-13 16:16:58, KOSAKI Motohiro wrote:
>> >>> You missed the "!".  I'm proposing that setting the new bit 2 will
>> >>> permit people to prevent the new printk if it is causing them problems.
>> >>
>> >> No I don't. I'm sure almost all abuse users think our usage is correct. Then,
>> >> I can imagine all crazy applications start to use this flag eventually.
>> >
>> > I guess we do not care about those. If somebody wants to shoot his feet
>> > then we cannot do much about it. The primary motivation was to find out
>> > those that think this is right and they are willing to change the setup
>> > once they know this is not the right way to do things.
>> >
>> > I think that giving a way to suppress the warning is a good step. Log
>> > level might be to coarse and sysctl would be an overkill.
>>
>> When Dave Hansen reported this issue originally, he explained a lot of userland
>> developer misuse /proc/drop_caches because they don't understand what
>> drop_caches do.
>> So, if they never understand the fact, why can we trust them? I have no
>> idea.
>
> Well, most of that usage I have come across was legacy scripts which
> happened to work at a certain point in time because we sucked.
> Thinks have changed but such scripts happen to survive a long time.
> We are primarily interested in those.

Well, if the main target is shell script, task_comm and pid don't help us
a lot. I suggest to add ppid too.

>
>> Or, if you have different motivation w/ Dave, please let me know it.
>
> We have seen reports where users complained about performance drop down
> when in fact the real culprit turned out to be such a clever script
> which dropped caches on the background thinking it will help to free
> some memory. Such cases are tedious to reveal.

Imagine such script have bit-2 and no logging output. Because
the script author think "we are doing the right thing".
Why distro guys want such suppress messages?


>> While the purpose is to shoot misuse, I don't think we can trust
>> userland app.  If "If somebody wants to shoot his feet then we cannot
>> do much about it." is true, this patch is useless. OK, we still catch
>> the right user.
>
> I do not think it is useless. It will print a message for all those
> users initially. It is a matter of user how to deal with it.

If it is userland matter, we don't need additional logging at all. userland
can write their own log. Again, if a crazy guys write blog "Hey! we should
use echo 7 > /proc/sys/vm/drop_caches" always, we will come back the
original problem. You and Dave wrote we need to care wrong, rumor and
crazy drop_caches usage. And if so, you need to think new additional
crazy rumor.


>> But we never want to know who is the right users, right?
>
> Well, those that are curious about a new message in the lock and come
> back to us asking what is going on are those we are primarily interested
> in.

I didn't say the message is useless. I did say hidden drop-cache user
is useless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
