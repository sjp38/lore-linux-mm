Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A27FC04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:27:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4109727B53
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:27:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="qksX5wzs";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="kAhOfNEO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4109727B53
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C96CF6B026A; Mon,  3 Jun 2019 00:27:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6C2D6B026B; Mon,  3 Jun 2019 00:27:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5C3B6B026C; Mon,  3 Jun 2019 00:27:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9253B6B026A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:27:09 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c4so13708352qkd.16
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:27:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=z9n041mVBoMx+lU8lmhyG3phiO4dUW1z+lGS4cRtV5s=;
        b=BqSfl3rIdvOsvw9i3YV3Nc4H/GNDJ2f8sUn9LaDHjYtC+1tU76glxN+RaU5hJQR9cw
         xq4YndQ1KH61Em41r9jAxuP0WCPctvMZrjCVT6avs4lXSdnz7o4jVKm/mPxKuJAdvxbP
         vxvujZ04UwXGenpgzVTQ60hm6dxLgY8xliWIrWvFeheTvRX5FteyAPuKv4OAtzmjapFi
         VCGYE1nLTdmoEjoYTJZ01oj8BEv3NytYOe5Nk7ApT5eNXF98RHAy2la2hz2NgQyokd3G
         YMTfeTs4hxQRVyvEH0aoCDC8QPmCVHVNKDpCdhWdPo84Fv3kjcg01nisowElMxHjIhSD
         /dHg==
X-Gm-Message-State: APjAAAU+LI0E0b5sZXzk5qCwSp+I3iuAfZwBFhRgcZf9zPX0ltEwfXBI
	ttciRmOEDb8F+lDupe/SZYtx2yzOc+p+cYK7iZh/b5PmGwiFzcJLvd5Jsotbc4phHupLUVu2i1Z
	Ths15retFdVPjMhfSWIYIvsKh83NKKFdqldSbF0acF3TmkgAQrVh5bXq2m6JhOwS14A==
X-Received: by 2002:a37:dc41:: with SMTP id v62mr13715508qki.251.1559536029233;
        Sun, 02 Jun 2019 21:27:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyloyHqo/7mKNzAYXGPhpl5pEZXHqtyOB7fUkxW2JFq51YLtiGxOd+y3wA3yI2x98iR9Xny
X-Received: by 2002:a37:dc41:: with SMTP id v62mr13715460qki.251.1559536028364;
        Sun, 02 Jun 2019 21:27:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559536028; cv=none;
        d=google.com; s=arc-20160816;
        b=VciH+SsDTyfqenMJxD4Nq2pcdiENaARt9wcrnJtquMAKnlMQa2jHxlJ9Uai9TEeVd3
         P8njFyqhBzgsnNfLvT47pHhPxG/fgXvFBk2WRJOy/G6xg4v36/g0GcNXM/PbG8cjLdKc
         YZ1eK4cVvXJbNrNCofH0crttxRJD5g+Rya7gaBt+T3qerNmxPtc0urtJsPX/Nrvr0C5v
         AK3/FFSw7FEW5nJNomOn1xLjI9+4eoxkGdDTHPEZTojDcDHgRHjPEoSp9CXJ7sl9JHgj
         hdSyaNlPYeKg1R9zBmrmK2JEFkEci/mMGwQJKjzjtPZwt6+0ef5Y08Y8B4bRj3uREunH
         ZAVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=z9n041mVBoMx+lU8lmhyG3phiO4dUW1z+lGS4cRtV5s=;
        b=q1Ln1yrTMldowqYamPoCp3kSYGsD4K0MCnWX/AqysvbfiNW35mipeSHdDxRxrMXArC
         vF+F1MiwU9EL4dbXjhhQmXXtvhAISXzhmTPUDda6sMvsQBMlmenhiAf/3vtvSBaJAjvQ
         yxYqJC1+SDdfh2XuiOitFnSv4WAt0tQ7t6EZmxBobQaplzYz/C25NcFKtCuKNrkdn/fA
         DOcvoQZVERKR/OLbXNg97MLgMxeC/OS2nGuZPDgz3ToFcOfusmDgaIeEFumq298SwPS/
         H0txE1mQWmzxwVlvXwG6JfARVr13T5oN7wbtsBxaO6bzMenuaNXK/I/mnTyZ6/RKgsJO
         cLFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b=qksX5wzs;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=kAhOfNEO;
       spf=neutral (google.com: 66.111.4.230 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id w51si1652460qtb.275.2019.06.02.21.27.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 21:27:08 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.230 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b=qksX5wzs;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=kAhOfNEO;
       spf=neutral (google.com: 66.111.4.230 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailnew.nyi.internal (Postfix) with ESMTP id DBC2D123E;
	Mon,  3 Jun 2019 00:27:07 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Mon, 03 Jun 2019 00:27:07 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm3; bh=z9n041mVBoMx+lU8lmhyG3phiO4
	dUW1z+lGS4cRtV5s=; b=qksX5wzsra2tYynWZhegmrL/72S5klpK2oTRqt1rsWS
	smwkyrb0XtcXmGCptBP7qRU+Tj4zHAHmr9+Ttlc+ew0+ZwQ6nvucSxTzNvcGduBn
	B8VoEgz32xnmMBYWfyUcwASTDRzUqvOwadevUAYK3P0ckPFOhW05cJMGofWN5A4B
	itF8HvoxMseJaeg+wXqepRhT0FlG99OV1GWUNC4XjYgyYbC7kagv2gWf0gCb2whx
	uFWbMzr9HOGJjdUmIi+VdGpgaxrCcFzIWVh2nLO8HQxaU3m4DifGlsBEYdBpHuwr
	ZIoLqP80wNrqdrOOOkYm1hAKS/1XSx+2fz887CGstWQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=z9n041
	mVBoMx+lU8lmhyG3phiO4dUW1z+lGS4cRtV5s=; b=kAhOfNEOtQESkNPK/QgoFR
	ioYb980SjObemXQqu5rWpyDRd9kll0AzwfrmTgmt5ANtRAzShlUkUSFrWbSZOSdE
	ceZpvYZVvYGypA3K5lm54xk6jdOYImRuothJQUXgBUyw8r8dus1DFuOwccpl12AF
	m3tMunnoo8ScUmzfSt47mHvYeJlQIHJK8z97fztcVDy8il89eoi0qrDB3/ujfEKb
	8PadHRzBbIgfJpFjpmfuVqDjBjlm6DpwOUgj+iFVRr9GPXBX7UIh/Zl65PceLu7m
	wi0xigtqFvyadEkmuJ0nINWGieKwcHzz8FI4JnanlJQzPiYGJCAXd9Dl0u4RnKfg
	==
X-ME-Sender: <xms:l6H0XKQzXbuonbb3UP4TgqpY6CCDT0nQhhRv9OYBRUa1eGn-ZQMRkw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudefiedgkedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    gfrhhlucfvnfffucdlfedtmdenucfjughrpeffhffvuffkfhggtggujgfofgesthdtredt
    ofervdenucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtoh
    gsihhnrdgttgeqnecukfhppeduvdegrddugeelrdduudefrdefieenucfrrghrrghmpehm
    rghilhhfrhhomhepmhgvsehtohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:l6H0XP9KjYpAiNvTS1MfuedY3zJXLP_8ha9aJmBysHyOU8U1iIMJbA>
    <xmx:l6H0XJpReFxW0eBpwvqekelSmmqLqCwQk8bEHuS-1lQIDbrCTlaLeA>
    <xmx:l6H0XEmYSSgn9uupwEN-ZdKr_WuQiZ1e1gdfLfYAB3hbhrmAVyDdiQ>
    <xmx:m6H0XB25yu1H9mUyEsVQ0nMIxjwfKuCgZNRjUEfJrXi_-9cn1V0l_Q>
Received: from localhost (124-149-113-36.dyn.iinet.net.au [124.149.113.36])
	by mail.messagingengine.com (Postfix) with ESMTPA id 6920938008B;
	Mon,  3 Jun 2019 00:27:02 -0400 (EDT)
Date: Mon, 3 Jun 2019 14:26:20 +1000
From: "Tobin C. Harding" <me@tobin.cc>
To: Roman Gushchin <guro@fb.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>, Jonathan Corbet <corbet@lwn.net>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH v5 16/16] dcache: Add CONFIG_DCACHE_SMO
Message-ID: <20190603042620.GA23098@eros.localdomain>
References: <20190520054017.32299-1-tobin@kernel.org>
 <20190520054017.32299-17-tobin@kernel.org>
 <20190521005740.GA9552@tower.DHCP.thefacebook.com>
 <20190521013118.GB25898@eros.localdomain>
 <20190521020530.GA18287@tower.DHCP.thefacebook.com>
 <20190529035406.GA23181@eros.localdomain>
 <20190529161644.GA3228@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529161644.GA3228@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.12.0 (2019-05-25)
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 04:16:51PM +0000, Roman Gushchin wrote:
> On Wed, May 29, 2019 at 01:54:06PM +1000, Tobin C. Harding wrote:
> > On Tue, May 21, 2019 at 02:05:38AM +0000, Roman Gushchin wrote:
> > > On Tue, May 21, 2019 at 11:31:18AM +1000, Tobin C. Harding wrote:
> > > > On Tue, May 21, 2019 at 12:57:47AM +0000, Roman Gushchin wrote:
> > > > > On Mon, May 20, 2019 at 03:40:17PM +1000, Tobin C. Harding wrote:
> > > > > > In an attempt to make the SMO patchset as non-invasive as possible add a
> > > > > > config option CONFIG_DCACHE_SMO (under "Memory Management options") for
> > > > > > enabling SMO for the DCACHE.  Whithout this option dcache constructor is
> > > > > > used but no other code is built in, with this option enabled slab
> > > > > > mobility is enabled and the isolate/migrate functions are built in.
> > > > > > 
> > > > > > Add CONFIG_DCACHE_SMO to guard the partial shrinking of the dcache via
> > > > > > Slab Movable Objects infrastructure.
> > > > > 
> > > > > Hm, isn't it better to make it a static branch? Or basically anything
> > > > > that allows switching on the fly?
> > > > 
> > > > If that is wanted, turning SMO on and off per cache, we can probably do
> > > > this in the SMO code in SLUB.
> > > 
> > > Not necessarily per cache, but without recompiling the kernel.
> > > > 
> > > > > It seems that the cost of just building it in shouldn't be that high.
> > > > > And the question if the defragmentation worth the trouble is so much
> > > > > easier to answer if it's possible to turn it on and off without rebooting.
> > > > 
> > > > If the question is 'is defragmentation worth the trouble for the
> > > > dcache', I'm not sure having SMO turned off helps answer that question.
> > > > If one doesn't shrink the dentry cache there should be very little
> > > > overhead in having SMO enabled.  So if one wants to explore this
> > > > question then they can turn on the config option.  Please correct me if
> > > > I'm wrong.
> > > 
> > > The problem with a config option is that it's hard to switch over.
> > > 
> > > So just to test your changes in production a new kernel should be built,
> > > tested and rolled out to a representative set of machines (which can be
> > > measured in thousands of machines). Then if results are questionable,
> > > it should be rolled back.
> > > 
> > > What you're actually guarding is the kmem_cache_setup_mobility() call,
> > > which can be perfectly avoided using a boot option, for example. Turning
> > > it on and off completely dynamic isn't that hard too.
> > 
> > Hi Roman,
> > 
> > I've added a boot parameter to SLUB so that admins can enable/disable
> > SMO at boot time system wide.  Then for each object that implements SMO
> > (currently XArray and dcache) I've also added a boot parameter to
> > enable/disable SMO for that cache specifically (these depend on SMO
> > being enabled system wide).
> > 
> > All three boot parameters default to 'off', I've added a config option
> > to default each to 'on'.
> > 
> > I've got a little more testing to do on another part of the set then the
> > PATCH version is coming at you :)
> > 
> > This is more a courtesy email than a request for comment, but please
> > feel free to shout if you don't like the method outlined above.
> > 
> > Fully dynamic config is not currently possible because currently the SMO
> > implementation does not support disabling mobility for a cache once it
> > is turned on, a bit of extra logic would need to be added and some state
> > stored - I'm not sure it warrants it ATM but that can be easily added
> > later if wanted.  Maybe Christoph will give his opinion on this.
> 
> Perfect!

Hi Roman,

I'm about to post PATCH series.  I have removed all the boot time config
options in contrast to what I stated in this thread.  I feel it requires
some comment so as not to seem rude to you.  Please feel free to
re-raise these issues on the series if you feel it is a better place to
do it than on this thread.

I still hear you re making testing easier if there are boot parameters.
I don't have extensive experience testing on a large number of machines
so I have no basis to contradict what you said.

It was suggested to me that having switches to turn SMO off implies the
series is not ready.  I am claiming that SMO _is_ ready and also that it
has no negative effects (especially on the dcache).  I therefore think
this comment is pertinent.

So ... I re-did the boot parameters defaulting to 'on'.  However I could
then see no reason (outside of testing) to turn them off.  It seems ugly
to have code that is only required during testing and never after.
Please correct me if I'm wrong.

Finally I decided that since adding a boot parameter is trivial that
hackers could easily add one to test if they wanted to test a specific
cache.  Otherwise we just test 'patched kernel' vs 'unpatched kernel'.
Again, please correct me if I'm wrong.

So, that said, please feel free to voice your opinion as strongly as you
wish.  I am super appreciative of the time you have already taken to
look at these patches.  I hope I have made the best technical decision,
and I am totally open to being told I'm wrong :)

thanks,
Tobin.

